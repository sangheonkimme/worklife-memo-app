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
                    const SizedBox(height: 16),
                    _buildFolderPicker(foldersAsync),
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
    final theme = Theme.of(context);
    final folders = folderAsync.asData?.value ?? const <Folder>[];
    String? selectedFolderName;
    if (_selectedFolderId != null) {
      for (final folder in folders) {
        if (folder.id == _selectedFolderId) {
          selectedFolderName = folder.name;
          break;
        }
      }
    }
    final isLoading = folderAsync is AsyncLoading<List<Folder>>;
    final hasError = folderAsync is AsyncError<List<Folder>>;
    final displayText = isLoading
        ? '폴더 불러오는 중...'
        : (selectedFolderName ?? '폴더 없음');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (isLoading) {
                return;
              }
              _openFolderPicker(folders: folders);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: '폴더',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              isEmpty: displayText.isEmpty,
              child: Text(
                displayText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isLoading
                      ? theme.disabledColor
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '폴더를 불러오지 못했습니다.\n${folderAsync.error}',
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Future<void> _openFolderPicker({required List<Folder> folders}) async {
    final result =
        await showModalBottomSheet<({bool createNew, int? folderId})>(
      context: context,
      builder: (context) => _FolderPickerSheet(
        folders: folders,
        selectedFolderId: _selectedFolderId,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (result.createNew) {
      await _showCreateFolderDialog();
      return;
    }

    setState(() {
      _selectedFolderId = result.folderId;
    });
  }

  Future<void> _showCreateFolderDialog() async {
    final messenger = ScaffoldMessenger.of(context);

    var input = '';
    var showValidationError = false;

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('새 폴더'),
              content: TextField(
                autofocus: true,
                onChanged: (value) {
                  setDialogState(() {
                    input = value;
                    if (showValidationError && value.trim().isNotEmpty) {
                      showValidationError = false;
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: '폴더 이름',
                  errorText:
                      showValidationError ? '폴더 이름을 입력해주세요.' : null,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('취소'),
                ),
                FilledButton(
                  onPressed: () {
                    final trimmed = input.trim();
                    if (trimmed.isEmpty) {
                      setDialogState(() {
                        showValidationError = true;
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(trimmed);
                  },
                  child: const Text('추가'),
                ),
              ],
            );
          },
        );
      },
    );

    if (name == null) {
      return;
    }

    final createFolder = await ref.read(createFolderProvider.future);
    final result = await createFolder(name);

    if (!mounted) {
      return;
    }

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

class _FolderPickerSheet extends StatelessWidget {
  const _FolderPickerSheet({
    required this.folders,
    required this.selectedFolderId,
  });

  final List<Folder> folders;
  final int? selectedFolderId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '폴더 선택',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.all_inbox_outlined),
              title: const Text('폴더 없음'),
              trailing:
                  selectedFolderId == null ? const Icon(Icons.check) : null,
              onTap: () =>
                  Navigator.of(context).pop((createNew: false, folderId: null)),
            ),
            ...folders.map(
              (folder) => ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(folder.name),
                trailing: folder.id == selectedFolderId
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(context)
                    .pop((createNew: false, folderId: folder.id)),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text('새 폴더 추가'),
              onTap: () => Navigator.of(context)
                  .pop((createNew: true, folderId: null)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
