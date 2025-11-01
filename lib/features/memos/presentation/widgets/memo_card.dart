import 'package:flutter/material.dart';

import '../../domain/entities/memo.dart';

class MemoCard extends StatelessWidget {
  const MemoCard({
    super.key,
    required this.memo,
    this.folderName,
    this.onTap,
    this.onTogglePin,
  });

  final Memo memo;
  final String? folderName;
  final VoidCallback? onTap;
  final VoidCallback? onTogglePin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = memo.title.trim().isEmpty ? '제목 없음' : memo.title.trim();
    final content = memo.content.trim().isEmpty
        ? '내용 없음'
        : memo.content.trim().replaceAll('\n', ' ');

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.topCenter,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      memo.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: theme.textTheme.titleMedium?.fontSize ?? 20,
                    ),
                    tooltip: memo.isPinned ? '핀 해제' : '핀 고정',
                    onPressed: onTogglePin,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.8,
                  ),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (folderName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        folderName!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  if (folderName != null) const SizedBox(width: 8),
                  Text(
                    _formatDateTime(memo.updatedAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final mm = dateTime.minute.toString().padLeft(2, '0');
    return '$y.$m.$d $hh:$mm';
  }
}
