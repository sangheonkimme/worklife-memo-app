import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/providers.dart' as di;
import '../../../../core/error/failure.dart';
import '../../domain/entities/folder.dart';
import '../../domain/usecases/create_folder.dart';
import '../../domain/usecases/watch_folders.dart';

part 'folder_list_controller.g.dart';

@Riverpod(keepAlive: true)
Future<WatchFolders> watchFolders(WatchFoldersRef ref) async {
  final repository = await ref.watch(di.folderRepositoryProvider.future);
  return WatchFolders(repository);
}

@Riverpod(keepAlive: true)
Future<CreateFolder> createFolder(CreateFolderRef ref) async {
  final repository = await ref.watch(di.folderRepositoryProvider.future);
  return CreateFolder(repository);
}

@Riverpod(keepAlive: true)
Stream<List<Folder>> folderList(FolderListRef ref) async* {
  final watch = await ref.watch(watchFoldersProvider.future);
  await for (final result in watch()) {
    yield result.fold(
      (failure) => throw _FolderFailureException(failure),
      (value) => value,
    );
  }
}

class _FolderFailureException implements Exception {
  _FolderFailureException(this.failure);

  final Failure failure;

  @override
  String toString() => failure.message;
}
