import '../../../../core/result/result.dart';
import '../entities/folder.dart';
import '../repositories/folder_repository.dart';

class WatchFolders {
  const WatchFolders(this._repository);

  final FolderRepository _repository;

  Stream<Result<List<Folder>>> call() {
    return _repository.watchFolders();
  }
}
