import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notepad/widgets/app_slidable.dart';

import '../models/checklist.dart';

class ChecklistCard extends StatelessWidget {
  final Checklist checklist;
  final int totalCount;
  final int checkedCount;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;
  final VoidCallback onShareTap;
  final VoidCallback onBookmarkTap;

  const ChecklistCard({
    super.key,
    required this.checklist,
    required this.totalCount,
    required this.checkedCount,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
    required this.onShareTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final progress =
        totalCount == 0 ? 0.0 : checkedCount / totalCount;

    return AppSlidable(
      bookmarkIcon: checklist.isBookmarked
        ? Icons.bookmark
        : Icons.bookmark_border,

      onBookmark: onBookmarkTap,
      onShare: onShareTap,
      onDelete: onDelete,
      additionalActions: [
        AppSlidableAction(
          onPressed: onRename,
          backgroundColor: Colors.green,
          foregroundColor: colors.onPrimary,
          icon: Icons.edit,
        ),
      ],

      child: Container(
        color: colors.secondary,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        checklist.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor:
                              colors.surfaceContainerHighest,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                            colors.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Text(
                      '$checkedCount/$totalCount',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSecondary,
                      ),
                    ),

                    
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  DateFormat('MMM d, yyyy · h:mm a').format(checklist.updatedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSecondary
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}