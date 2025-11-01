import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../folders/domain/entities/folder.dart';
import '../../../folders/presentation/controllers/folder_list_controller.dart';
import '../controllers/memo_editor_controller.dart';
import '../controllers/memo_editor_state.dart';

class MemoEditorPage extends ConsumerStatefulWidget {
  const MemoEditorPage({super.key, this.memoId});

  final int? memoId;

  @override
  ConsumerState<MemoEditorPage> createState() => _MemoEditorPageState();
}

class _MemoEditorPageState extends ConsumerState<MemoEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isPinned = false;
  int? _selectedFolderId;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editorAsync = ref.watch(
      memoEditorControllerProvider(memoId: widget.memoId),
    );

    return editorAsync.when(
      data: (editorState) {
        _syncState(editorState);
        final foldersAsync = ref.watch(folderListProvider);
        final isSaving = editorState.isSaving;
        final errorMessage = editorState.errorMessage;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.memoId == null ? '새 메모' : '메모 수정'),
            actions: [
              IconButton(
                tooltip: _isPinned ? '핀 해제' : '핀 고정',
                icon: Icon(
                  _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                ),
                onPressed: () => setState(() {
                  _isPinned = !_isPinned;
                }),
              ),
              if (widget.memoId != null)
                IconButton(
                  tooltip: '삭제',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: isSaving ? null : _onDelete,
                ),
              TextButton(
                onPressed: isSaving ? null : _onSave,
                child: const Text('저장'),
              ),
            ],
          ),
          body: Stack(
            children: [
              AbsorbPointer(
                absorbing: isSaving,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: '제목',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFolderPicker(foldersAsync),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: _isPinned,
                      onChanged: (value) {
                        setState(() {
                          _isPinned = value;
                        });
                      },
                      title: const Text('핀 고정'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: '내용',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                      minLines: 8,
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              if (isSaving)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.05),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('메모 편집')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(
                  '메모를 불러올 수 없습니다.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(
                    memoEditorControllerProvider(memoId: widget.memoId),
                  ),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _syncState(MemoEditorState state) {
    if (_initialized) {
      return;
    }

    _titleController.text = state.memo.title;
    _contentController.text = state.memo.content;
    _isPinned = state.memo.isPinned;
    _selectedFolderId = state.memo.folderId;
    _initialized = true;
  }

  Widget _buildFolderPicker(AsyncValue<List<Folder>> folderAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: DropdownMenu<int?>(
            key: ValueKey(_selectedFolderId),
            initialSelection: _selectedFolderId,
            label: const Text('폴더'),
            dropdownMenuEntries: [
              const DropdownMenuEntry<int?>(value: null, label: '폴더 없음'),
              ...folderAsync.asData?.value
                      .map(
                        (folder) => DropdownMenuEntry<int?>(
                          value: folder.id,
                          label: folder.name,
                        ),
                      )
                      .toList() ??
                  [],
            ],
            onSelected: (value) {
              setState(() {
                _selectedFolderId = value;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _showCreateFolderDialog,
            icon: const Icon(Icons.create_new_folder_outlined),
            label: const Text('새 폴더 추가'),
          ),
        ),
        if (folderAsync is AsyncError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '폴더를 불러오지 못했습니다.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }

  Future<void> _showCreateFolderDialog() async {
    final nameController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 폴더'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: '폴더 이름'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              final text = nameController.text.trim();
              if (text.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('폴더 이름을 입력해주세요.')),
                );
                return;
              }
              Navigator.of(context).pop(text);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );

    nameController.dispose();

    if (name == null) {
      return;
    }

    final createFolder = ref.read(createFolderProvider);
    final result = await createFolder(name);

    result.fold(
      (failure) {
        messenger.showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (id) {
        setState(() {
          _selectedFolderId = id;
        });
        ref.invalidate(folderListProvider);
      },
    );
  }

  Future<void> _onSave() async {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(
      memoEditorControllerProvider(memoId: widget.memoId).notifier,
    );

    final result = await notifier.save(
      title: _titleController.text,
      content: _contentController.text,
      folderId: _selectedFolderId,
      isPinned: _isPinned,
    );

    result.fold(
      (failure) =>
          messenger.showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        messenger.showSnackBar(const SnackBar(content: Text('메모를 저장했습니다.')));
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _onDelete() async {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(
      memoEditorControllerProvider(memoId: widget.memoId).notifier,
    );
    final result = await notifier.remove();

    result.fold(
      (failure) =>
          messenger.showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        messenger.showSnackBar(const SnackBar(content: Text('메모를 삭제했습니다.')));
        Navigator.of(context).pop();
      },
    );
  }
}
