import '../../domain/entities/memo.dart';

class MemoEditorState {
  const MemoEditorState({
    required this.memo,
    this.isSaving = false,
    this.errorMessage,
  });

  final Memo memo;
  final bool isSaving;
  final String? errorMessage;

  MemoEditorState copyWith({
    Memo? memo,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MemoEditorState(
      memo: memo ?? this.memo,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
