import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/folders/data/datasources/folder_local_ds.dart';
import '../../features/folders/data/entities/folder_entity.dart';
import '../../features/folders/data/repositories/folder_repository_impl.dart';
import '../../features/folders/domain/repositories/folder_repository.dart';
import '../../features/memos/data/datasources/memo_local_ds.dart';
import '../../features/memos/data/entities/memo_entity.dart';
import '../../features/memos/data/repositories/memo_repository_impl.dart';
import '../../features/memos/domain/repositories/memo_repository.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
Future<Isar> isar(IsarRef ref) async {
  final existing = Isar.getInstance();
  if (existing != null) {
    return existing;
  }

  final dir = await getApplicationDocumentsDirectory();

  return Isar.open([MemoEntitySchema, FolderEntitySchema], directory: dir.path);
}

@Riverpod(keepAlive: true)
MemoLocalDataSource memoLocalDataSource(MemoLocalDataSourceRef ref) {
  final isar = ref.watch(isarProvider.future);
  return MemoLocalDataSource(isar: isar);
}

@Riverpod(keepAlive: true)
FolderLocalDataSource folderLocalDataSource(FolderLocalDataSourceRef ref) {
  final isar = ref.watch(isarProvider.future);
  return FolderLocalDataSource(isar: isar);
}

@Riverpod(keepAlive: true)
MemoRepository memoRepository(MemoRepositoryRef ref) {
  return MemoRepositoryImpl(
    memoLocalDataSource: ref.watch(memoLocalDataSourceProvider),
  );
}

@Riverpod(keepAlive: true)
FolderRepository folderRepository(FolderRepositoryRef ref) {
  return FolderRepositoryImpl(
    localDataSource: ref.watch(folderLocalDataSourceProvider),
  );
}
