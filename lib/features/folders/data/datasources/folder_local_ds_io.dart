import 'dart:async';

import 'package:isar/isar.dart';

import '../entities/folder_entity.dart';

class FolderLocalDataSource {
  FolderLocalDataSource({Future<Isar>? isar})
    : _isarFuture =
          isar ??
          (throw ArgumentError('Isar future is required on this platform.'));

  final Future<Isar> _isarFuture;

  Stream<List<FolderEntity>> watchAll() {
    return Stream.fromFuture(_isarFuture).asyncExpand((isar) {
      return isar.folderEntitys.where().sortBySortOrder().watch(
        fireImmediately: true,
      );
    });
  }

  Future<int> create(String name) async {
    final isar = await _isarFuture;

    return isar.writeTxn(() async {
      final last = await isar.folderEntitys
          .where()
          .sortBySortOrderDesc()
          .findFirst();
      final nextOrder = (last?.sortOrder ?? 0) + 1;
      final entity = FolderEntity(
        name: name,
        sortOrder: nextOrder,
        createdAt: DateTime.now(),
      );

      return isar.folderEntitys.put(entity);
    });
  }
}
