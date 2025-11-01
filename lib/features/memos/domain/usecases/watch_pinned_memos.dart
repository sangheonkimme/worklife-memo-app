import '../../../../core/result/result.dart';
import '../entities/memo.dart';
import '../repositories/memo_repository.dart';

class WatchPinnedMemos {
  const WatchPinnedMemos(this._repository);

  final MemoRepository _repository;

  Stream<Result<List<Memo>>> call({String? query}) {
    return _repository.watchPinnedMemos(query: query);
  }
}
