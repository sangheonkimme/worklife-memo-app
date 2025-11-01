import 'package:freezed_annotation/freezed_annotation.dart';

part 'memo.freezed.dart';
part 'memo.g.dart';

@freezed
class Memo with _$Memo {
  const factory Memo({
    int? id,
    required String title,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isPinned,
    int? folderId,
  }) = _Memo;

  factory Memo.fromJson(Map<String, dynamic> json) => _$MemoFromJson(json);
}
