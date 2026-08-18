import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      note.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: note.isBookmarked
                          ? theme.colorScheme.primary
                          : theme.iconTheme.color,
                    ),
                    onPressed: onBookmarkTap,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    DateFormat('MMM d, yyyy · h:mm a').format(note.updatedAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
