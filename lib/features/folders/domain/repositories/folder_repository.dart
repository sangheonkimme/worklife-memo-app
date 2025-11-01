import '../../../../core/result/result.dart';
import '../entities/folder.dart';

abstract class FolderRepository {
  Stream<Result<List<Folder>>> watchFolders();

  Future<Result<int>> createFolder(String name);
}
