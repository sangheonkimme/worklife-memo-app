import 'dart:async';

import 'package:worklife_memo_app/core/error/failure.dart';
import 'package:worklife_memo_app/core/result/result.dart';
import 'package:worklife_memo_app/features/folders/domain/entities/folder.dart';
import 'package:worklife_memo_app/features/folders/domain/repositories/folder_repository.dart';
import 'package:worklife_memo_app/features/memos/domain/entities/memo.dart';
import 'package:worklife_memo_app/features/memos/domain/repositories/memo_repository.dart';

class FakeMemoRepository implements MemoRepository {
  FakeMemoRepository() {
    _allController = StreamController<Result<List<Memo>>>.broadcast(
      onListen: _emit,
    );
    _pinnedController = StreamController<Result<List<Memo>>>.broadcast(
      onListen: _emit,
    );
    _emit();
  }

  final Map<int, Memo> _store = <int, Memo>{};
  int _nextId = 1;
  late final StreamController<Result<List<Memo>>> _allController;
  late final StreamController<Result<List<Memo>>> _pinnedController;
  final List<int> toggledIds = <int>[];

  @override
  Stream<Result<List<Memo>>> watchMemos({String? query, int? folderId}) {
    final normalizedQuery = query?.trim().toLowerCase();
    return _allController.stream.map((result) {
      if (result is Err<List<Memo>>) {
        return result;
      }
      final data = (result as Ok<List<Memo>>).value.where((memo) {
        final matchesQuery =
            normalizedQuery == null ||
            normalizedQuery.isEmpty ||
            memo.title.toLowerCase().contains(normalizedQuery) ||
            memo.content.toLowerCase().contains(normalizedQuery);
        final matchesFolder = folderId == null || memo.folderId == folderId;
        return matchesQuery && matchesFolder;
      }).toList();
      return Ok<List<Memo>>(List.unmodifiable(data));
    });
  }

  @override
  Stream<Result<List<Memo>>> watchPinnedMemos({String? query}) {
    final normalizedQuery = query?.trim().toLowerCase();
    return _pinnedController.stream.map((result) {
      if (result is Err<List<Memo>>) {
        return result;
      }
      final data = (result as Ok<List<Memo>>).value.where((memo) {
        final matchesQuery =
            normalizedQuery == null ||
            normalizedQuery.isEmpty ||
            memo.title.toLowerCase().contains(normalizedQuery) ||
            memo.content.toLowerCase().contains(normalizedQuery);
        return matchesQuery;
      }).toList();
      return Ok<List<Memo>>(List.unmodifiable(data));
    });
  }

  @override
  Future<Result<Memo?>> getMemo(int id) async {
    return Ok(_store[id]);
  }

  @override
  Future<Result<int>> upsertMemo(Memo memo) async {
    final id = memo.id ?? _nextId++;
    final stored = memo.copyWith(id: id);
    _store[id] = stored;
    _emit();
    return Ok(id);
  }

  @override
  Future<Result<void>> deleteMemo(int id) async {
    if (_store.remove(id) == null) {
      return const Err(StorageFailure('메모가 존재하지 않습니다.'));
    }
    _emit();
    return const Ok(null);
  }

  @override
  Future<Result<void>> togglePin({
    required int id,
    required bool isPinned,
  }) async {
    final memo = _store[id];
    if (memo == null) {
      return const Err(StorageFailure('메모가 존재하지 않습니다.'));
    }
    _store[id] = memo.copyWith(isPinned: isPinned, updatedAt: DateTime.now());
    toggledIds.add(id);
    _emit();
    return const Ok(null);
  }

  void dispose() {
    _allController.close();
    _pinnedController.close();
  }

  void _emit() {
    if (_allController.isClosed || _pinnedController.isClosed) return;
    final memos = _store.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _allController.add(Ok(List.unmodifiable(memos)));
    final pinned = memos.where((memo) => memo.isPinned).toList();
    _pinnedController.add(Ok(List.unmodifiable(pinned)));
  }

  List<Memo> get storedMemos =>
      _store.values.toList()..sort((a, b) => a.id!.compareTo(b.id!));
}

class FakeFolderRepository implements FolderRepository {
  FakeFolderRepository() {
    _controller = StreamController<Result<List<Folder>>>.broadcast(
      onListen: _emit,
    );
    _emit();
  }

  final List<Folder> _folders = <Folder>[];
  int _nextId = 1;
  int _nextSortOrder = 1;
  late final StreamController<Result<List<Folder>>> _controller;

  @override
  Stream<Result<List<Folder>>> watchFolders() {
    return _controller.stream;
  }

  @override
  Future<Result<int>> createFolder(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Err(StorageFailure('폴더 이름은 비워둘 수 없습니다.'));
    }
    final folder = Folder(
      id: _nextId++,
      name: trimmed,
      sortOrder: _nextSortOrder++,
      createdAt: DateTime.now(),
    );
    _folders.add(folder);
    _emit();
    return Ok(folder.id!);
  }

  void dispose() {
    _controller.close();
  }

  void _emit() {
    if (_controller.isClosed) {
      return;
    }
    final sorted = _folders.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _controller.add(Ok(List.unmodifiable(sorted)));
  }

  List<Folder> get folders =>
      _folders.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
}
