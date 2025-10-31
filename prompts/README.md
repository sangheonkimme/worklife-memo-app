# Flutter Riverpod + Isar Starter

Minimal starter using **Riverpod 2** and **Isar**. Includes clean foldering, Result/Failure primitives, DI providers, and a Notes feature (list + add).

## Quick Start

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome   # or ios / android / macos
```

## Requirements

- Flutter 3.22+ / Dart 3.4+
- Xcode/cocoapods (iOS) or Android Studio + SDK/AVD (Android)
- Packages: flutter_riverpod, riverpod_annotation, isar, isar_flutter_libs, build_runner

## Pubspec (excerpt)

```yaml
name: riverpod_isar_starter
publish_to: 'none'

environment:
  sdk: '>=3.4.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.3
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.3
  uuid: ^4.4.2
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  freezed: ^2.5.7
  json_serializable: ^6.8.0
```

## Folder Structure

```text
lib/
  app/
    main.dart
    di/providers.dart
  core/
    error/failure.dart
    result/result.dart
  features/
    notes/
      domain/
        entities/note.dart
        repositories/note_repository.dart
        usecases/create_note.dart
        usecases/get_notes.dart
      data/
        entities/note_entity.dart
        datasources/note_local_ds.dart
        repositories/note_repository_impl.dart
      presentation/
        controllers/notes_controller.dart
        pages/notes_page.dart
```

> Run generators after changes to `@collection` models or `@riverpod` providers: `dart run build_runner build -d`

## Core Primitives

**core/error/failure.dart**

```dart
sealed class Failure { final String message; const Failure(this.message); }
class StorageFailure extends Failure { const StorageFailure(super.message); }
class UnknownFailure extends Failure { const UnknownFailure(super.message); }
```

**core/result/result.dart**

```dart
sealed class Result<T> { const Result(); R fold<R>(R Function(Failure) l, R Function(T) r); }
class Ok<T> extends Result<T> { final T value; const Ok(this.value); @override R fold<R>(R Function(Failure) l, R Function(T) r) => r(value); }
class Err<T> extends Result<T> { final Failure failure; const Err(this.failure); @override R fold<R>(R Function(Failure) l, R Function(T) r) => l(failure); }
```

## Domain Layer

**features/notes/domain/entities/note.dart**

```dart
class Note { final String id; final String title; final DateTime createdAt; final bool isPinned; const Note({required this.id, required this.title, required this.createdAt, this.isPinned = false}); }
```

**features/notes/domain/repositories/note_repository.dart**

```dart
import 'package:riverpod_isar_starter/core/result/result.dart';
import '../entities/note.dart';
abstract class NoteRepository {
  Future<Result<List<Note>>> getNotes();
  Future<Result<void>> createNote(String title, {bool isPinned = false});
}
```

**features/notes/domain/usecases/get_notes.dart**

```dart
import 'package:riverpod_isar_starter/core/result/result.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';
class GetNotes { final NoteRepository repo; GetNotes(this.repo); Future<Result<List<Note>>> call() => repo.getNotes(); }
```

**features/notes/domain/usecases/create_note.dart**

```dart
import 'package:riverpod_isar_starter/core/result/result.dart';
import '../repositories/note_repository.dart';
class CreateNote { final NoteRepository repo; CreateNote(this.repo); Future<Result<void>> call(String title, {bool isPinned = false}) => repo.createNote(title, isPinned: isPinned); }
```

## Data Layer (Isar)

**features/notes/data/entities/note_entity.dart**

```dart
import 'package:isar/isar.dart';
import '../../domain/entities/note.dart';

part 'note_entity.g.dart';

@collection
class NoteEntity {
  Id idIsar = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String uuid;
  late String title;
  late DateTime createdAt;
  late bool isPinned;

  Note toDomain() => Note(id: uuid, title: title, createdAt: createdAt, isPinned: isPinned);
  static NoteEntity fromDomain(Note n) => NoteEntity()
    ..uuid = n.id
    ..title = n.title
    ..createdAt = n.createdAt
    ..isPinned = n.isPinned;
}
```

**features/notes/data/datasources/note_local_ds.dart**

```dart
import 'dart:async';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../entities/note_entity.dart';

class NoteLocalDataSource {
  static Isar? _isar;
  static Future<Isar> _db() async {
    if (_isar != null) return _isar!;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([NoteEntitySchema], directory: dir.path);
    return _isar!;
  }

  Future<List<NoteEntity>> getAll() async {
    final isar = await _db();
    return isar.noteEntitys.where().sortByCreatedAtDesc().findAll();
  }

  Future<void> upsert(NoteEntity e) async {
    final isar = await _db();
    await isar.writeTxn(() async { await isar.noteEntitys.put(e); });
  }
}
```

**features/notes/data/repositories/note_repository_impl.dart**

```dart
import 'package:uuid/uuid.dart';
import 'package:riverpod_isar_starter/core/error/failure.dart';
import 'package:riverpod_isar_starter/core/result/result.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_local_ds.dart';
import '../entities/note_entity.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource local;
  NoteRepositoryImpl(this.local);

  @override
  Future<Result<List<Note>>> getNotes() async {
    try {
      final rows = await local.getAll();
      return Ok(rows.map((e) => e.toDomain()).toList());
    } catch (e) {
      return Err(StorageFailure('Failed to load notes: $e'));
    }
  }

  @override
  Future<Result<void>> createNote(String title, {bool isPinned = false}) async {
    try {
      final id = const Uuid().v4();
      final entity = NoteEntity()
        ..uuid = id
        ..title = title
        ..createdAt = DateTime.now()
        ..isPinned = isPinned;
      await local.upsert(entity);
      return Ok(null);
    } catch (e) {
      return Err(StorageFailure('Failed to create note: $e'));
    }
  }
}
```

## DI Providers (Riverpod)

**app/di/providers.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/notes/data/datasources/note_local_ds.dart';
import '../../features/notes/data/repositories/note_repository_impl.dart';
import '../../features/notes/domain/repositories/note_repository.dart';
import '../../features/notes/domain/usecases/create_note.dart';
import '../../features/notes/domain/usecases/get_notes.dart';

part 'providers.g.dart';

@riverpod
NoteLocalDataSource noteLocalDs(NoteLocalDsRef ref) => NoteLocalDataSource();

@riverpod
NoteRepository noteRepository(NoteRepositoryRef ref) =>
    NoteRepositoryImpl(ref.watch(noteLocalDsProvider));

@riverpod
GetNotes getNotes(GetNotesRef ref) => GetNotes(ref.watch(noteRepositoryProvider));

@riverpod
CreateNote createNote(CreateNoteRef ref) => CreateNote(ref.watch(noteRepositoryProvider));
```

> Generate providers: `dart run build_runner build --delete-conflicting-outputs`

## Presentation Layer

**features/notes/presentation/controllers/notes_controller.dart**

```dart
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/domain/usecases/get_notes.dart';
import '../../../notes/domain/usecases/create_note.dart';
import '../../../../app/di/providers.dart';

part 'notes_controller.g.dart';

@riverpod
class NotesController extends _$NotesController {
  @override
  FutureOr<List<Note>> build() async {
    final res = await ref.read(getNotesProvider).call();
    return res.fold((l) => throw Exception(l.message), (r) => r);
  }

  Future<void> add(String title) async {
    final r = await ref.read(createNoteProvider).call(title);
    r.fold((l) => throw Exception(l.message), (_) {});
    ref.invalidateSelf();
  }
}
```

**features/notes/presentation/pages/notes_page.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/notes_controller.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotes = ref.watch(notesControllerProvider);
    final controller = ref.read(notesControllerProvider.notifier);

    final textCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Notes (Riverpod + Isar)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: textCtrl,
                  decoration: const InputDecoration(hintText: 'New note title'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final t = textCtrl.text.trim();
                  if (t.isNotEmpty) {
                    await controller.add(t);
                    textCtrl.clear();
                  }
                },
                child: const Text('Add'),
              )
            ]),
            const SizedBox(height: 16),
            Expanded(
              child: asyncNotes.when(
                data: (notes) => ListView.separated(
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final n = notes[i];
                    return ListTile(
                      title: Text(n.title),
                      subtitle: Text(n.createdAt.toIso8601String()),
                      trailing: n.isPinned ? const Icon(Icons.push_pin) : null,
                    );
                  },
                ),
                error: (e, st) => Center(child: Text('Error: $e')),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**app/main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/notes/presentation/pages/notes_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riverpod + Isar Starter',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const NotesPage(),
    );
  }
}
```

## Build Runner

```bash
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs
```

## Troubleshooting

- Include `isar_flutter_libs` or native libs will be missing at runtime.
- Re-run build_runner after changes to `@collection` or `@riverpod`.
- iOS first build: `flutter clean` and re-open in Xcode if pods act up.
- Android emulator: ensure `adb` on PATH, `flutter doctor` is green.
- Desktop Isar path: ensure valid writable dir via `path_provider`.

## Codex Task Checklist

- [ ] Create folders/files as shown
- [ ] Add dependencies from Pubspec section
- [ ] Paste code into exact file paths
- [ ] `flutter pub get`
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter run -d chrome` and verify adding notes works
- [ ] (Optional) pinned-first sorting in DAO
- [ ] (Optional) add go_router routes
