import '../../../../core/result/result.dart';
import '../entities/memo.dart';
import '../repositories/memo_repository.dart';

class WatchMemos {
  const WatchMemos(this._repository);

  final MemoRepository _repository;

  Stream<Result<List<Memo>>> call({String? query, int? folderId}) {
    return _repository.watchMemos(query: query, folderId: folderId);
  }
}
