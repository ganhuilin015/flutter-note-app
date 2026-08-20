import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:notepad/widgets/app_slidable.dart';
import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;
  final VoidCallback onShareTap;
  final VoidCallback onDeleteTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onBookmarkTap,
    required this.onShareTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppSlidable(
      bookmarkIcon: note.isBookmarked
        ? Icons.bookmark
        : Icons.bookmark_border,

      onBookmark: onBookmarkTap,
      onShare: onShareTap,
      onDelete: onDeleteTap,

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
                        note.title.isEmpty ? 'Untitled' : note.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                if (note.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      note.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                const SizedBox(height: 8),

                Text(
                  DateFormat('MMM d, yyyy · h:mm a').format(note.updatedAt),
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