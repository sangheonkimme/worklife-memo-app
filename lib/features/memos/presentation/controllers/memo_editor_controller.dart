import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/providers.dart' as di;
import '../../../../core/result/result.dart';
import '../../domain/entities/memo.dart';
import '../../domain/usecases/delete_memo.dart';
import '../../domain/usecases/toggle_pin.dart';
import '../../domain/usecases/upsert_memo.dart';
import 'memo_editor_state.dart';
import 'memo_list_controller.dart';

part 'memo_editor_controller.g.dart';

@Riverpod(keepAlive: true)
Future<UpsertMemo> upsertMemo(UpsertMemoRef ref) async {
  final repository = await ref.watch(di.memoRepositoryProvider.future);
  return UpsertMemo(repository);
}

@Riverpod(keepAlive: true)
Future<DeleteMemo> deleteMemo(DeleteMemoRef ref) async {
  final repository = await ref.watch(di.memoRepositoryProvider.future);
  return DeleteMemo(repository);
}

@Riverpod(keepAlive: true)
Future<TogglePin> togglePin(TogglePinRef ref) async {
  final repository = await ref.watch(di.memoRepositoryProvider.future);
  return TogglePin(repository);
}

@Riverpod()
class MemoEditorController extends _$MemoEditorController {
  @override
  FutureOr<MemoEditorState> build({int? memoId}) async {
    if (memoId != null) {
      final memo = await ref.watch(memoByIdProvider(memoId).future);
      if (memo == null) {
        throw Exception('메모를 찾을 수 없습니다.');
      }
      return MemoEditorState(memo: memo);
    }

    final now = DateTime.now();
    final memo = Memo(
      title: '',
      content: '',
      createdAt: now,
      updatedAt: now,
      isPinned: false,
    );
    return MemoEditorState(memo: memo);
  }

  Future<Result<int>> save({
    required String title,
    required String content,
    int? folderId,
    bool? isPinned,
  }) async {
    final current = state.requireValue;
    final updatedMemo = current.memo.copyWith(
      title: title,
      content: content,
      folderId: folderId,
      isPinned: isPinned ?? current.memo.isPinned,
      updatedAt: DateTime.now(),
    );

    state = AsyncData(
      current.copyWith(memo: updatedMemo, isSaving: true, clearError: true),
    );

    final upsert = await ref.read(upsertMemoProvider.future);
    final result = await upsert.call(updatedMemo);

    return result.fold(
      (failure) {
        state = AsyncData(
          current.copyWith(
            memo: current.memo,
            isSaving: false,
            errorMessage: failure.message,
          ),
        );
        return Err(failure);
      },
      (id) {
        final storedMemo = updatedMemo.copyWith(id: updatedMemo.id ?? id);
        state = AsyncData(
          current.copyWith(memo: storedMemo, isSaving: false, clearError: true),
        );
        return Ok(id);
      },
    );
  }

  Future<Result<void>> remove() async {
    final current = state.requireValue;
    final id = current.memo.id;
    if (id == null) {
      return const Ok(null);
    }

    state = AsyncData(current.copyWith(isSaving: true, clearError: true));

    final delete = await ref.read(deleteMemoProvider.future);
    final result = await delete.call(id);

    return result.fold(
      (failure) {
        state = AsyncData(
          current.copyWith(isSaving: false, errorMessage: failure.message),
        );
        return Err(failure);
      },
      (_) {
        state = AsyncData(current.copyWith(isSaving: false, clearError: true));
        return const Ok(null);
      },
    );
  }

  Future<Result<void>> togglePinned() async {
    final current = state.requireValue;
    final hasId = current.memo.id != null;
    final desired = !current.memo.isPinned;

    final optimisticMemo = current.memo.copyWith(
      isPinned: desired,
      updatedAt: DateTime.now(),
    );

    state = AsyncData(current.copyWith(memo: optimisticMemo, clearError: true));

    if (!hasId) {
      return const Ok(null);
    }

    final toggle = await ref.read(togglePinProvider.future);
    final result = await toggle.call(id: current.memo.id!, isPinned: desired);

    return result.fold((failure) {
      state = AsyncData(
        current.copyWith(memo: current.memo, errorMessage: failure.message),
      );
      return Err(failure);
    }, (_) => const Ok(null));
  }
}
