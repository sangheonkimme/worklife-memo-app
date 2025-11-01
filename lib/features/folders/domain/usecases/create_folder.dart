import '../../../../core/result/result.dart';
import '../repositories/folder_repository.dart';

class CreateFolder {
  const CreateFolder(this._repository);

  final FolderRepository _repository;

  Future<Result<int>> call(String name) {
    return _repository.createFolder(name);
  }
}
