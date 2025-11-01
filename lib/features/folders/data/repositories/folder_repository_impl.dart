import 'dart:async';

import 'package:isar/isar.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/folder.dart';
import '../../domain/repositories/folder_repository.dart';
import '../datasources/folder_local_ds.dart';
import '../entities/folder_entity.dart';

class FolderRepositoryImpl implements FolderRepository {
  FolderRepositoryImpl({required FolderLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final FolderLocalDataSource _localDataSource;

  @override
  Stream<Result<List<Folder>>> watchFolders() {
    return _localDataSource.watchAll().transform(_folderStreamTransformer);
  }

  @override
  Future<Result<int>> createFolder(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Err(StorageFailure('폴더 이름은 비워둘 수 없습니다.'));
    }

    try {
      final id = await _localDataSource.create(trimmed);
      return Ok(id);
    } on IsarError catch (e) {
      return Err(StorageFailure(e.message));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  StreamTransformer<List<FolderEntity>, Result<List<Folder>>>
  get _folderStreamTransformer {
    return StreamTransformer.fromHandlers(
      handleData: (entities, sink) {
        final folders = entities.map((e) => e.toDomain()).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        sink.add(Ok(folders));
      },
      handleError: (error, stackTrace, sink) {
        if (error is IsarError) {
          sink.add(Err(StorageFailure(error.message)));
        } else {
          sink.add(Err(UnknownFailure(error.toString())));
        }
      },
    );
  }
}
