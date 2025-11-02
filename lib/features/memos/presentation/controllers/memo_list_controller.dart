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
Future<WatchMemos> watchMemos(WatchMemosRef ref) async {
  final repository = await ref.watch(di.memoRepositoryProvider.future);
  return WatchMemos(repository);
}

@Riverpod(keepAlive: true)
Future<WatchPinnedMemos> watchPinnedMemos(WatchPinnedMemosRef ref) async {
  final repository = await ref.watch(di.memoRepositoryProvider.future);
  return WatchPinnedMemos(repository);
}

@Riverpod(keepAlive: true)
Future<GetMemo> getMemo(GetMemoRef ref) async {
  final repository = await ref.watch(di.memoRepositoryProvider.future);
  return GetMemo(repository);
}

@Riverpod(keepAlive: true)
Stream<List<Memo>> memoList(MemoListRef ref) async* {
  final query = ref.watch(memoSearchQueryProvider);
  final watch = await ref.watch(watchMemosProvider.future);
  final sanitized = query.trim().isEmpty ? null : query.trim();

  await for (final result in watch(query: sanitized)) {
    yield result.fold(
      (failure) => throw _MemoFailureException(failure),
      (value) => value,
    );
  }
}

@Riverpod(keepAlive: true)
Stream<List<Memo>> pinnedMemoList(PinnedMemoListRef ref) async* {
  final query = ref.watch(memoSearchQueryProvider);
  final watch = await ref.watch(watchPinnedMemosProvider.future);
  final sanitized = query.trim().isEmpty ? null : query.trim();

  await for (final result in watch(query: sanitized)) {
    yield result.fold(
      (failure) => throw _MemoFailureException(failure),
      (value) => value,
    );
  }
}

@Riverpod()
Future<Memo?> memoById(MemoByIdRef ref, int id) async {
  final getMemo = await ref.watch(getMemoProvider.future);
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
