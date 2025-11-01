import '../../../../core/result/result.dart';
import '../entities/memo.dart';
import '../repositories/memo_repository.dart';

class UpsertMemo {
  const UpsertMemo(this._repository);

  final MemoRepository _repository;

  Future<Result<int>> call(Memo memo) {
    return _repository.upsertMemo(memo);
  }
}
