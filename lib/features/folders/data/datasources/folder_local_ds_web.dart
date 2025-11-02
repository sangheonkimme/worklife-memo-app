import 'dart:async';

import '../entities/folder_entity.dart';

class FolderLocalDataSource {
  FolderLocalDataSource({Future<dynamic>? isar});

  final Map<int, FolderEntity> _store = <int, FolderEntity>{};
  int _nextId = 1;
  int _nextSortOrder = 1;

  late final StreamController<List<FolderEntity>> _controller =
      StreamController<List<FolderEntity>>.broadcast(
        onListen: () => _controller.add(_snapshot()),
      );

  Stream<List<FolderEntity>> watchAll() {
    return _controller.stream;
  }

  Future<int> create(String name) async {
    final id = _nextId++;
    final entity = FolderEntity(
      id: id,
      name: name,
      sortOrder: _nextSortOrder++,
      createdAt: DateTime.now(),
    );
    _store[id] = entity;
    _emit();
    return id;
  }

  List<FolderEntity> _snapshot() {
    final folders = _store.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return List.unmodifiable(folders);
  }

  void _emit() {
    _controller.add(_snapshot());
  }
}
