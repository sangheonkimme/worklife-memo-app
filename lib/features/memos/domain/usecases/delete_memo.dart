import '../../../../core/result/result.dart';
import '../repositories/memo_repository.dart';

class DeleteMemo {
  const DeleteMemo(this._repository);

  final MemoRepository _repository;

  Future<Result<void>> call(int id) {
    return _repository.deleteMemo(id);
  }
}
