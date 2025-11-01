import '../../../../core/result/result.dart';
import '../entities/memo.dart';

abstract class MemoRepository {
  Stream<Result<List<Memo>>> watchMemos({String? query, int? folderId});

  Stream<Result<List<Memo>>> watchPinnedMemos({String? query});

  Future<Result<Memo?>> getMemo(int id);

  Future<Result<int>> upsertMemo(Memo memo);

  Future<Result<void>> deleteMemo(int id);

  Future<Result<void>> togglePin({required int id, required bool isPinned});
}
