import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/memo.dart';
import '../../domain/usecases/get_memo.dart';
import '../../domain/usecases/watch_memos.dart';
import '../../domain/usecases/watch_pinned_memos.dart';
import '../../../../app/di/providers.dart' as di;
import 'memo_search_query.dart';

part 'memo_list_controller.g.dart';

@Riverpod(keepAlive: true)
WatchMemos watchMemos(WatchMemosRef ref) {
  final repository = ref.watch(di.memoRepositoryProvider);
  return WatchMemos(repository);
}

@Riverpod(keepAlive: true)
WatchPinnedMemos watchPinnedMemos(WatchPinnedMemosRef ref) {
  final repository = ref.watch(di.memoRepositoryProvider);
  return WatchPinnedMemos(repository);
}

@Riverpod(keepAlive: true)
GetMemo getMemo(GetMemoRef ref) {
  final repository = ref.watch(di.memoRepositoryProvider);
  return GetMemo(repository);
}

@Riverpod(keepAlive: true)
Stream<List<Memo>> memoList(MemoListRef ref) {
  final query = ref.watch(memoSearchQueryProvider);
  final watch = ref.watch(watchMemosProvider);
  final sanitized = query.trim().isEmpty ? null : query.trim();

  return watch(query: sanitized).asyncMap((result) {
    return result.fold(
      (failure) => throw _MemoFailureException(failure),
      (value) => value,
    );
  });
}

@Riverpod(keepAlive: true)
Stream<List<Memo>> pinnedMemoList(PinnedMemoListRef ref) {
  final query = ref.watch(memoSearchQueryProvider);
  final watch = ref.watch(watchPinnedMemosProvider);
  final sanitized = query.trim().isEmpty ? null : query.trim();

  return watch(query: sanitized).asyncMap((result) {
    return result.fold(
      (failure) => throw _MemoFailureException(failure),
      (value) => value,
    );
  });
}

@Riverpod()
Future<Memo?> memoById(MemoByIdRef ref, int id) async {
  final getMemo = ref.watch(getMemoProvider);
  final result = await getMemo(id);
  return result.fold(
    (failure) => throw _MemoFailureException(failure),
    (memo) => memo,
  );
}

class _MemoFailureException implements Exception {
  _MemoFailureException(this.failure);

  final Failure failure;

  @override
  String toString() => failure.message;
}
