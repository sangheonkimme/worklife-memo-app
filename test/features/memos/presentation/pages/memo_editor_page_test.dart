import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:worklife_memo_app/app/di/providers.dart';
import 'package:worklife_memo_app/features/memos/presentation/pages/memo_editor_page.dart';

import '../../../../support/fakes.dart';

void main() {
  testWidgets('MemoEditorPage allows creating folder and saving memo',
      (tester) async {
    final memoRepository = FakeMemoRepository();
    final folderRepository = FakeFolderRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memoRepositoryProvider.overrideWithValue(memoRepository),
          folderRepositoryProvider.overrideWithValue(folderRepository),
        ],
        child: const MaterialApp(
          home: MemoEditorPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).at(0),
      '회의록',
    );
    await tester.enterText(
      find.byType(TextField).at(1),
      'Agenda와 액션 아이템 정리',
    );

    await tester.tap(find.text('폴더 없음'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('새 폴더 추가'));
    await tester.pumpAndSettle();

    final dialogFieldFinder = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(dialogFieldFinder, '프로젝트 A');
    await tester.tap(find.text('추가'));
    await tester.pumpAndSettle();

    expect(find.text('프로젝트 A'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.push_pin_outlined));
    await tester.pump();
    expect(find.byIcon(Icons.push_pin), findsOneWidget);

    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(memoRepository.storedMemos, hasLength(1));
    final savedMemo = memoRepository.storedMemos.first;
    expect(savedMemo.title, '회의록');
    expect(savedMemo.isPinned, isTrue);
    expect(savedMemo.folderId, folderRepository.folders.first.id);
  });
}
