import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import 'package:worklife_memo_app/app/di/providers.dart';
import 'package:worklife_memo_app/features/memos/presentation/controllers/memo_editor_controller.dart';

import '../../../../support/fakes.dart';

void main() {
  group('MemoEditorController', () {
    late FakeMemoRepository memoRepository;
    late ProviderContainer container;

    setUp(() {
      memoRepository = FakeMemoRepository();
      container = ProviderContainer(
        overrides: [memoRepositoryProvider.overrideWithValue(memoRepository)],
      );
    });

    tearDown(() {
      container.dispose();
      memoRepository.dispose();
    });

    test('save creates memo and updates state with generated id', () async {
      await container.read(memoEditorControllerProvider().future);
      final notifier = container.read(memoEditorControllerProvider().notifier);

      final result = await notifier.save(title: '회의록', content: '주간 회의 메모');

      expect(result.isOk, isTrue);

      final state = container.read(memoEditorControllerProvider()).requireValue;
      expect(state.memo.id, isNotNull);
      expect(state.memo.title, '회의록');
      expect(memoRepository.storedMemos, hasLength(1));
    });

    test(
      'togglePinned without persisted memo only updates local state',
      () async {
        await container.read(memoEditorControllerProvider().future);
        final notifier = container.read(
          memoEditorControllerProvider().notifier,
        );

        final toggleResult = await notifier.togglePinned();
        expect(toggleResult.isOk, isTrue);

        final state = container
            .read(memoEditorControllerProvider())
            .requireValue;
        expect(state.memo.isPinned, isTrue);
        expect(memoRepository.toggledIds, isEmpty);
      },
    );

    test('remove deletes stored memo and leaves repository empty', () async {
      await container.read(memoEditorControllerProvider().future);
      final notifier = container.read(memoEditorControllerProvider().notifier);

      final saveResult = await notifier.save(
        title: '삭제 대상',
        content: '곧 삭제될 메모',
      );
      expect(saveResult.isOk, isTrue);

      final removeResult = await notifier.remove();
      expect(removeResult.isOk, isTrue);

      expect(memoRepository.storedMemos, isEmpty);
    });
  });
}
