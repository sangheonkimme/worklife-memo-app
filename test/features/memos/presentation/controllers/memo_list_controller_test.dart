import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import 'package:worklife_memo_app/app/di/providers.dart';
import 'package:worklife_memo_app/features/memos/presentation/controllers/memo_editor_controller.dart';
import 'package:worklife_memo_app/features/memos/presentation/controllers/memo_list_controller.dart';
import 'package:worklife_memo_app/features/memos/presentation/controllers/memo_search_query.dart';

import '../../../../support/fakes.dart';

void main() {
  group('Memo list providers', () {
    late FakeMemoRepository memoRepository;
    late ProviderContainer container;

    setUp(() async {
      memoRepository = FakeMemoRepository();
      container = ProviderContainer(
        overrides: [memoRepositoryProvider.overrideWithValue(memoRepository)],
      );

      await container.read(memoEditorControllerProvider().future);
    });

    tearDown(() {
      container.dispose();
      memoRepository.dispose();
    });

    test('emits saved memos and reacts to search query updates', () async {
      final editor = container.read(memoEditorControllerProvider().notifier);
      final captured = <List<String>>[];

      final sub = container.listen(
        memoListProvider,
        (_, next) => next.whenData(
          (memos) => captured.add(memos.map((m) => m.title).toList()),
        ),
        fireImmediately: true,
      );

      await pumpEventQueue();
      expect(captured.isEmpty ? <String>[] : captured.last, isEmpty);

      await editor.save(title: '프로젝트 계획', content: '세부 일정 정리');
      await pumpEventQueue();
      expect(captured.last, contains('프로젝트 계획'));

      await editor.save(title: '가계부 정리', content: '이번 달 지출');
      await pumpEventQueue();
      expect(captured.last, containsAll(['프로젝트 계획', '가계부 정리']));

      container.read(memoSearchQueryProvider.notifier).updateQuery('프로젝트');
      await pumpEventQueue();

      expect(captured.last, ['프로젝트 계획']);

      sub.close();
    });
  });
}
