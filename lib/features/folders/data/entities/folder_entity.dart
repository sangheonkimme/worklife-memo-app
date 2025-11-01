import 'package:isar/isar.dart';

import '../../domain/entities/folder.dart';

part 'folder_entity.g.dart';

@collection
class FolderEntity {
  FolderEntity({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
  });

  Id id;
  String name;
  int sortOrder;
  DateTime createdAt;

  Folder toDomain() {
    return Folder(
      id: id,
      name: name,
      sortOrder: sortOrder,
      createdAt: createdAt,
    );
  }

  void applyName(String newName) {
    name = newName;
  }

  static FolderEntity fromDomain(Folder folder) {
    return FolderEntity(
      id: folder.id ?? Isar.autoIncrement,
      name: folder.name,
      sortOrder: folder.sortOrder,
      createdAt: folder.createdAt,
    );
  }
}
