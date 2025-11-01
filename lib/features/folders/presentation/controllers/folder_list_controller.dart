import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/providers.dart' as di;
import '../../../../core/error/failure.dart';
import '../../domain/entities/folder.dart';
import '../../domain/usecases/create_folder.dart';
import '../../domain/usecases/watch_folders.dart';

part 'folder_list_controller.g.dart';

@Riverpod(keepAlive: true)
WatchFolders watchFolders(WatchFoldersRef ref) {
  final repository = ref.watch(di.folderRepositoryProvider);
  return WatchFolders(repository);
}

@Riverpod(keepAlive: true)
CreateFolder createFolder(CreateFolderRef ref) {
  final repository = ref.watch(di.folderRepositoryProvider);
  return CreateFolder(repository);
}

@Riverpod(keepAlive: true)
Stream<List<Folder>> folderList(FolderListRef ref) {
  final watch = ref.watch(watchFoldersProvider);
  return watch().asyncMap((result) {
    return result.fold(
      (failure) => throw _FolderFailureException(failure),
      (value) => value,
    );
  });
}

class _FolderFailureException implements Exception {
  _FolderFailureException(this.failure);

  final Failure failure;

  @override
  String toString() => failure.message;
}
