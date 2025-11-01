import 'package:isar/isar.dart';

import '../../domain/entities/memo.dart';

part 'memo_entity.g.dart';

@collection
class MemoEntity {
  MemoEntity({
    this.id = Isar.autoIncrement,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.folderId,
  }) : searchText = buildSearchText(title, content);

  Id id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  bool isPinned;
  int? folderId;

  @Index(caseSensitive: false)
  String searchText;

  Memo toDomain() {
    return Memo(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPinned: isPinned,
      folderId: folderId,
    );
  }

  static MemoEntity fromDomain(Memo memo) {
    return MemoEntity(
      id: memo.id ?? Isar.autoIncrement,
      title: memo.title,
      content: memo.content,
      createdAt: memo.createdAt,
      updatedAt: memo.updatedAt,
      isPinned: memo.isPinned,
      folderId: memo.folderId,
    );
  }

  static String buildSearchText(String title, String content) {
    final buffer = StringBuffer()
      ..write(title.toLowerCase())
      ..write(' ')
      ..write(content.toLowerCase());
    return buffer.toString();
  }
}
