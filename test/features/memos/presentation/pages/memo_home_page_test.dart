import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:worklife_memo_app/app/di/providers.dart';
import 'package:worklife_memo_app/features/memos/domain/entities/memo.dart';
import 'package:worklife_memo_app/features/memos/presentation/pages/memo_home_page.dart';

import '../../../../support/fakes.dart';

void main() {
  testWidgets('MemoHomePage renders pinned and unpinned memos, toggles pin',
      (tester) async {
    final memoRepository = FakeMemoRepository();
    final folderRepository = FakeFolderRepository();

    final folderResult = await folderRepository.createFolder('업무');
    final folderId = folderResult.fold(
      (failure) => throw Exception(failure.message),
      (value) => value,
    );

    final now = DateTime(2024, 1, 10, 9, 30);
    await memoRepository.upsertMemo(
      Memo(
        title: '주간 리포트',
        content: '요약 정리',
        createdAt: now,
        updatedAt: now,
        isPinned: true,
        folderId: folderId,
      ),
    );
    await memoRepository.upsertMemo(
      Memo(
        title: '회의 준비',
        content: '어젠다 작성',
        createdAt: now.subtract(const Duration(minutes: 5)),
        updatedAt: now.subtract(const Duration(minutes: 5)),
        isPinned: false,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memoRepositoryProvider.overrideWithValue(memoRepository),
          folderRepositoryProvider.overrideWithValue(folderRepository),
        ],
        child: const MaterialApp(
          home: MemoHomePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('핀 고정된 메모'), findsOneWidget);
    expect(find.text('주간 리포트'), findsWidgets);
    expect(find.text('업무'), findsOneWidget);
    expect(find.text('회의 준비'), findsOneWidget);

    await tester.tap(find.widgetWithIcon(IconButton, Icons.push_pin).first);
    await tester.pumpAndSettle();

    expect(find.text('핀 고정된 메모'), findsNothing);
    expect(
      memoRepository.storedMemos.where((memo) => memo.isPinned).length,
      equals(0),
    );
  });
}
