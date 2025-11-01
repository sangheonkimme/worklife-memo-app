import '../../../../core/result/result.dart';
import '../repositories/memo_repository.dart';

class TogglePin {
  const TogglePin(this._repository);

  final MemoRepository _repository;

  Future<Result<void>> call({required int id, required bool isPinned}) {
    return _repository.togglePin(id: id, isPinned: isPinned);
  }
}
