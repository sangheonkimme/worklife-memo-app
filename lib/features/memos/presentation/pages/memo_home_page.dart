import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../folders/domain/entities/folder.dart';
import '../../../folders/presentation/controllers/folder_list_controller.dart';
import '../../domain/entities/memo.dart';
import '../controllers/memo_list_controller.dart';
import '../controllers/memo_search_query.dart';
import '../controllers/memo_editor_controller.dart';
import '../widgets/memo_card.dart';
import 'memo_editor_page.dart';

class MemoHomePage extends ConsumerStatefulWidget {
  const MemoHomePage({super.key});

  @override
  ConsumerState<MemoHomePage> createState() => _MemoHomePageState();
}

class _MemoHomePageState extends ConsumerState<MemoHomePage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(memoSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memoAsync = ref.watch(memoListProvider);
    final pinnedAsync = ref.watch(pinnedMemoListProvider);
    final folderAsync = ref.watch(folderListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('워크라이프 메모')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildMemoContent(
                memoAsync: memoAsync,
                pinnedAsync: pinnedAsync,
                folderAsync: folderAsync,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        ref.read(memoSearchQueryProvider.notifier).updateQuery(value);
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: '메모 검색',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  ref.read(memoSearchQueryProvider.notifier).clear();
                  setState(() {});
                },
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      onEditingComplete: () => FocusScope.of(context).unfocus(),
    );
  }

  Widget _buildMemoContent({
    required AsyncValue<List<Memo>> memoAsync,
    required AsyncValue<List<Memo>> pinnedAsync,
    required AsyncValue<List<Folder>> folderAsync,
  }) {
    return memoAsync.when(
      data: (memos) {
        final pinned = pinnedAsync.maybeWhen(
          data: (value) => value,
          orElse: () => memos.where((m) => m.isPinned).toList(),
        );
        final folderNameById = <int, String>{
          for (final folder in folderAsync.asData?.value ?? <Folder>[])
            if (folder.id != null) folder.id!: folder.name,
        };
        final unpinned = memos.where((memo) => !memo.isPinned).toList();

        if (memos.isEmpty) {
          return _EmptyState(onCreateTapped: () => _openEditor(context));
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(memoListProvider);
            ref.invalidate(pinnedMemoListProvider);
            ref.invalidate(folderListProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (pinned.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '핀 고정된 메모',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...pinned.map(
                        (memo) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: MemoCard(
                            memo: memo,
                            folderName: memo.folderId != null
                                ? folderNameById[memo.folderId!]
                                : null,
                            onTap: () => _openEditor(context, memoId: memo.id),
                            onTogglePin: () => _togglePin(memo),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                    ],
                  ),
                ),
              if (unpinned.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final memo = unpinned[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MemoCard(
                        memo: memo,
                        folderName: memo.folderId != null
                            ? folderNameById[memo.folderId!]
                            : null,
                        onTap: () => _openEditor(context, memoId: memo.id),
                        onTogglePin: () => _togglePin(memo),
                      ),
                    );
                  }, childCount: unpinned.length),
                ),
              if (unpinned.isEmpty && pinned.isNotEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: SizedBox.shrink(),
                ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => _ErrorState(
        message: '메모를 불러오지 못했습니다.\n${error.toString()}',
        onRetry: () {
          ref.invalidate(memoListProvider);
          ref.invalidate(pinnedMemoListProvider);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _openEditor(BuildContext context, {int? memoId}) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => MemoEditorPage(memoId: memoId)));
  }

  Future<void> _togglePin(Memo memo) async {
    if (memo.id == null) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final toggle = await ref.read(togglePinProvider.future);
    final result = await toggle(id: memo.id!, isPinned: !memo.isPinned);

    result.fold(
      (failure) =>
          messenger.showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {},
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateTapped});

  final VoidCallback onCreateTapped;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sticky_note_2_outlined, size: 48),
          const SizedBox(height: 12),
          const Text('메모가 없습니다. 새 메모를 작성해 보세요.'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onCreateTapped,
            icon: const Icon(Icons.add),
            label: const Text('새 메모 만들기'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
