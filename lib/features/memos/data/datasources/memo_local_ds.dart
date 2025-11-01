import 'dart:async';

import 'package:isar/isar.dart';

import '../../domain/entities/memo.dart';
import '../entities/memo_entity.dart';

class MemoLocalDataSource {
  MemoLocalDataSource({required Future<Isar> isar}) : _isarFuture = isar;

  final Future<Isar> _isarFuture;

  Stream<List<MemoEntity>> watchAll({String? query, int? folderId}) {
    return _watch(query: query, folderId: folderId, pinnedOnly: false);
  }

  Stream<List<MemoEntity>> watchPinned({String? query}) {
    return _watch(query: query, pinnedOnly: true);
  }

  Future<MemoEntity?> getById(int id) async {
    final isar = await _isarFuture;
    return isar.memoEntitys.get(id);
  }

  Future<int> upsert(Memo memo) async {
    final isar = await _isarFuture;
    final entity = MemoEntity.fromDomain(memo);

    return isar.writeTxn(() async {
      return isar.memoEntitys.put(entity);
    });
  }

  Future<void> delete(int id) async {
    final isar = await _isarFuture;
    await isar.writeTxn(() async {
      await isar.memoEntitys.delete(id);
    });
  }

  Future<void> togglePin({required int id, required bool isPinned}) async {
    final isar = await _isarFuture;
    await isar.writeTxn(() async {
      final entity = await isar.memoEntitys.get(id);
      if (entity != null) {
        entity.isPinned = isPinned;
        entity.updatedAt = DateTime.now();
        entity.searchText = _computeSearchText(entity.title, entity.content);
        await isar.memoEntitys.put(entity);
      }
    });
  }

  Stream<List<MemoEntity>> _watch({
    String? query,
    int? folderId,
    bool pinnedOnly = false,
  }) {
    final trimmed = query?.trim();

    return Stream.fromFuture(_isarFuture).asyncExpand((isar) {
      var qb = isar.memoEntitys.filter();

      if (pinnedOnly) {
        qb = qb.isPinnedEqualTo(true);
      }

      if (folderId != null) {
        qb = qb.folderIdEqualTo(folderId);
      }

      if (trimmed != null && trimmed.isNotEmpty) {
        qb = qb.searchTextContains(trimmed.toLowerCase());
      }

      final query = (qb as dynamic).build() as Query<MemoEntity>;
      return query.watch(fireImmediately: true);
    });
  }

  String _computeSearchText(String title, String content) {
    final buffer = StringBuffer()
      ..write(title.toLowerCase())
      ..write(' ')
      ..write(content.toLowerCase());
    return buffer.toString();
  }
}
