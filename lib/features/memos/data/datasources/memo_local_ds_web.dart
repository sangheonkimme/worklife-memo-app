import 'dart:async';

import '../../domain/entities/memo.dart';
import '../entities/memo_entity.dart';

class MemoLocalDataSource {
  MemoLocalDataSource({Future<dynamic>? isar});

  final Map<int, MemoEntity> _store = <int, MemoEntity>{};
  int _nextId = 1;

  late final StreamController<List<MemoEntity>> _controller =
      StreamController<List<MemoEntity>>.broadcast(
        onListen: () => _controller.add(_snapshot()),
      );

  Stream<List<MemoEntity>> watchAll({String? query, int? folderId}) {
    final normalized = query?.trim().toLowerCase();
    return _controller.stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (entities, sink) {
          sink.add(
            _filter(
              entities,
              normalized: normalized,
              folderId: folderId,
              pinnedOnly: false,
            ),
          );
        },
      ),
    );
  }

  Stream<List<MemoEntity>> watchPinned({String? query}) {
    final normalized = query?.trim().toLowerCase();
    return _controller.stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (entities, sink) {
          sink.add(
            _filter(
              entities,
              normalized: normalized,
              folderId: null,
              pinnedOnly: true,
            ),
          );
        },
      ),
    );
  }

  Future<MemoEntity?> getById(int id) async {
    return _store[id];
  }

  Future<int> upsert(Memo memo) async {
    final now = DateTime.now();
    final id = memo.id ?? _nextId++;
    final entity = MemoEntity(
      id: id,
      title: memo.title,
      content: memo.content,
      createdAt: memo.id == null ? now : memo.createdAt,
      updatedAt: now,
      isPinned: memo.isPinned,
      folderId: memo.folderId,
    );
    _store[id] = entity;
    _emit();
    return id;
  }

  Future<void> delete(int id) async {
    _store.remove(id);
    _emit();
  }

  Future<void> togglePin({required int id, required bool isPinned}) async {
    final entity = _store[id];
    if (entity == null) {
      return;
    }
    _store[id] = MemoEntity(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: DateTime.now(),
      isPinned: isPinned,
      folderId: entity.folderId,
    );
    _emit();
  }

  List<MemoEntity> _filter(
    List<MemoEntity> source, {
    required String? normalized,
    required int? folderId,
    required bool pinnedOnly,
  }) {
    final result =
        source.where((entity) {
          if (pinnedOnly && !entity.isPinned) {
            return false;
          }
          if (folderId != null && entity.folderId != folderId) {
            return false;
          }
          if (normalized != null && normalized.isNotEmpty) {
            return entity.searchText.contains(normalized);
          }
          return true;
        }).toList()..sort((a, b) {
          if (a.isPinned != b.isPinned) {
            return a.isPinned ? -1 : 1;
          }
          return b.updatedAt.compareTo(a.updatedAt);
        });
    return List.unmodifiable(result);
  }

  List<MemoEntity> _snapshot() {
    final entities = _store.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.unmodifiable(entities);
  }

  void _emit() {
    _controller.add(_snapshot());
  }
}
