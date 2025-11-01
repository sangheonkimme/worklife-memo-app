import '../../../../core/result/result.dart';
import '../entities/memo.dart';
import '../repositories/memo_repository.dart';

class GetMemo {
  const GetMemo(this._repository);

  final MemoRepository _repository;

  Future<Result<Memo?>> call(int id) {
    return _repository.getMemo(id);
  }
}
