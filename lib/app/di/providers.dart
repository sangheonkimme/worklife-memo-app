import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/folders/data/datasources/folder_local_ds.dart';
import '../../features/folders/data/entities/folder_entity.dart';
import '../../features/folders/data/repositories/folder_repository_impl.dart';
import '../../features/folders/domain/repositories/folder_repository.dart';
import '../../features/memos/data/datasources/memo_local_ds.dart';
import '../../features/memos/data/entities/memo_entity.dart';
import '../../features/memos/data/repositories/memo_repository_impl.dart';
import '../../features/memos/domain/repositories/memo_repository.dart';
import 'isar_directory.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
Future<Isar> isar(IsarRef ref) async {
  final existing = Isar.getInstance();
  if (existing != null) {
    return existing;
  }

  if (kIsWeb) {
    throw UnsupportedError('Isar is not supported on the web platform.');
  }

  const schemas = [MemoEntitySchema, FolderEntitySchema];
  final directoryPath = await resolveIsarDirectory();
  if (directoryPath == null || directoryPath.isEmpty) {
    throw UnsupportedError('Failed to resolve Isar storage directory.');
  }
  await prepareResolvedIsarDirectory(directoryPath);

  try {
    return await Isar.open(
      schemas,
      directory: directoryPath,
      name: 'worklife_memo',
    );
  } on IsarError catch (error) {
    final message = error.message;
    const schemaMismatchError = 'Collection id is invalid';
    if (message.contains(schemaMismatchError)) {
      await clearIsarDirectory(directoryPath);
      await prepareResolvedIsarDirectory(directoryPath);
      return Isar.open(
        schemas,
        directory: directoryPath,
        name: 'worklife_memo',
      );
    }
    rethrow;
  }
}

@Riverpod(keepAlive: true)
Future<MemoLocalDataSource> memoLocalDataSource(
  MemoLocalDataSourceRef ref,
) async {
  if (kIsWeb) {
    return MemoLocalDataSource();
  }
  final isar = await ref.watch(isarProvider.future);
  return MemoLocalDataSource(isar: Future.value(isar));
}

@Riverpod(keepAlive: true)
Future<FolderLocalDataSource> folderLocalDataSource(
  FolderLocalDataSourceRef ref,
) async {
  if (kIsWeb) {
    return FolderLocalDataSource();
  }
  final isar = await ref.watch(isarProvider.future);
  return FolderLocalDataSource(isar: Future.value(isar));
}

@Riverpod(keepAlive: true)
Future<MemoRepository> memoRepository(MemoRepositoryRef ref) async {
  final dataSource = await ref.watch(memoLocalDataSourceProvider.future);
  return MemoRepositoryImpl(
    memoLocalDataSource: dataSource,
  );
}

@Riverpod(keepAlive: true)
Future<FolderRepository> folderRepository(FolderRepositoryRef ref) async {
  final dataSource = await ref.watch(folderLocalDataSourceProvider.future);
  return FolderRepositoryImpl(
    localDataSource: dataSource,
  );
}
