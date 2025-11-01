import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:worklife_memo_app/features/memos/data/datasources/memo_local_ds.dart';
import 'package:worklife_memo_app/features/memos/data/entities/memo_entity.dart';
import 'package:worklife_memo_app/features/memos/domain/entities/memo.dart';

Future<void> main() async {
  final libPath =
      '${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev/isar_flutter_libs-3.1.0+1/macos/libisar.dylib';
  await Isar.initializeIsarCore(libraries: {Abi.macosArm64: libPath});

  final dir = await Directory.systemTemp.createTemp('isar_debug');
  final isar = await Isar.open(
    [MemoEntitySchema],
    directory: dir.path,
    inspector: false,
  );
  final dataSource = MemoLocalDataSource(isar: Future.value(isar));

  final stream = dataSource.watchAll();
  final sub = stream.listen((event) {
    print('watch -> ${event.length} items');
  });

  await Future<void>.delayed(const Duration(milliseconds: 200));

  final now = DateTime.now();
  await dataSource.upsert(
    Memo(
      title: 'Test',
      content: 'Content',
      createdAt: now,
      updatedAt: now,
    ),
  );

  await Future<void>.delayed(const Duration(milliseconds: 200));

  await sub.cancel();
  await isar.close(deleteFromDisk: true);
  await dir.delete(recursive: true);
}
