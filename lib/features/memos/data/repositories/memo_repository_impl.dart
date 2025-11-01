import 'dart:async';

import 'package:isar/isar.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/memo.dart';
import '../../domain/repositories/memo_repository.dart';
import '../datasources/memo_local_ds.dart';
import '../entities/memo_entity.dart';

class MemoRepositoryImpl implements MemoRepository {
  MemoRepositoryImpl({required MemoLocalDataSource memoLocalDataSource})
    : _memoLocalDataSource = memoLocalDataSource;

  final MemoLocalDataSource _memoLocalDataSource;

  @override
  Stream<Result<List<Memo>>> watchMemos({String? query, int? folderId}) {
    return _memoLocalDataSource
        .watchAll(query: query, folderId: folderId)
        .transform(_memoStreamTransformer);
  }

  @override
  Stream<Result<List<Memo>>> watchPinnedMemos({String? query}) {
    return _memoLocalDataSource
        .watchPinned(query: query)
        .transform(_memoStreamTransformer);
  }

  @override
  Future<Result<Memo?>> getMemo(int id) async {
    try {
      final entity = await _memoLocalDataSource.getById(id);
      return Ok(entity?.toDomain());
    } on IsarError catch (e) {
      return Err(StorageFailure(e.message));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> upsertMemo(Memo memo) async {
    try {
      final now = DateTime.now();
      final updatedMemo = memo.copyWith(
        createdAt: memo.id == null ? now : memo.createdAt,
        updatedAt: now,
      );

      final id = await _memoLocalDataSource.upsert(updatedMemo);
      return Ok(id);
    } on IsarError catch (e) {
      return Err(StorageFailure(e.message));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteMemo(int id) async {
    try {
      await _memoLocalDataSource.delete(id);
      return const Ok(null);
    } on IsarError catch (e) {
      return Err(StorageFailure(e.message));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> togglePin({
    required int id,
    required bool isPinned,
  }) async {
    try {
      await _memoLocalDataSource.togglePin(id: id, isPinned: isPinned);
      return const Ok(null);
    } on IsarError catch (e) {
      return Err(StorageFailure(e.message));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  StreamTransformer<List<MemoEntity>, Result<List<Memo>>>
  get _memoStreamTransformer {
    return StreamTransformer.fromHandlers(
      handleData: (entities, sink) {
        final sorted = entities.map((entity) => entity.toDomain()).toList()
          ..sort(_memoSorter);
        sink.add(Ok(sorted));
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

  int _memoSorter(Memo a, Memo b) {
    if (a.isPinned != b.isPinned) {
      return a.isPinned ? -1 : 1;
    }
    return b.updatedAt.compareTo(a.updatedAt);
  }
}
