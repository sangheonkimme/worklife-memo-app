import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import 'package:worklife_memo_app/app/di/providers.dart';
import 'package:worklife_memo_app/features/folders/presentation/controllers/folder_list_controller.dart';

import '../../../../support/fakes.dart';

void main() {
  group('Folder list providers', () {
    late FakeFolderRepository folderRepository;
    late ProviderContainer container;

    setUp(() {
      folderRepository = FakeFolderRepository();
      container = ProviderContainer(
        overrides: [
          folderRepositoryProvider.overrideWithValue(folderRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      folderRepository.dispose();
    });

    test('createFolder updates folderList stream in sort order', () async {
      final captured = <List<String>>[];

      final sub = container.listen(
        folderListProvider,
        (_, next) => next.whenData(
          (folders) => captured.add(folders.map((f) => f.name).toList()),
        ),
        fireImmediately: true,
      );

      await pumpEventQueue();
      expect(captured.isEmpty ? <String>[] : captured.last, isEmpty);

      final createFolder = container.read(createFolderProvider);
      final firstResult = await createFolder('Work');
      expect(firstResult.isOk, isTrue);
      await pumpEventQueue();
      expect(captured.last, ['Work']);

      final secondResult = await createFolder('Life');
      expect(secondResult.isOk, isTrue);
      await pumpEventQueue();
      expect(captured.last, ['Work', 'Life']);

      sub.close();
    });

    test('createFolder returns failure for blank names', () async {
      final createFolder = container.read(createFolderProvider);
      final result = await createFolder('   ');

      expect(result.isErr, isTrue);
      result.fold(
        (failure) => expect(failure.message, '폴더 이름은 비워둘 수 없습니다.'),
        (_) => fail('빈 폴더명은 성공하면 안 됩니다.'),
      );
    });
  });
}
