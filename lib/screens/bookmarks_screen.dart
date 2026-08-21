import 'package:flutter/material.dart';
import 'package:notepad/utils/checklist_dialogs.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../models/checklist.dart';
import '../providers/notes_provider.dart';
import '../providers/checklist_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/checklist_card.dart';
import 'note_edit_screen.dart';
import 'checklist_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotesProvider, ChecklistProvider>(
      builder: (context, notesProvider, checklistProvider, _) {
        final notes = notesProvider.bookmarkedNotes;
        final checklists = checklistProvider.bookmarkedChecklists;

        if (notes.isEmpty && checklists.isEmpty) {
          return const _EmptyBookmarks();
        }

        final List<BookmarkItem> bookmarks = [
          ...notes.map(
            (note) => BookmarkItem.fromNote(note),
          ),
          ...checklists.map(
            (checklist) => BookmarkItem.fromChecklist(checklist),
          ),
        ];

        bookmarks.sort(
          (a, b) => b.updatedAt.compareTo(a.updatedAt),
        );

        return ListView(
          padding: const EdgeInsets.all(28),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (int i = 0; i < bookmarks.length; i++) ...[
                    _buildBookmarkCard(
                      context,
                      bookmarks[i],
                      notesProvider,
                      checklistProvider,
                    ),

                    if (i < bookmarks.length - 1)
                      Divider(
                        height: 0.5,
                        thickness: 0.25,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookmarkCard(
    BuildContext context,
    BookmarkItem bookmark,
    NotesProvider notesProvider,
    ChecklistProvider checklistProvider,
  ) {

    if (bookmark.type == BookmarkType.note) {
      final note = bookmark.note!;

      return NoteCard(
        note: note,

        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NoteEditScreen(note: note),
            ),
          );
        },

        onBookmarkTap: () {
          notesProvider.toggleBookmark(note.id);
        },

        onShareTap: () {
          // TODO: Share note
        },

        onDeleteTap: () {
          notesProvider.deleteNote(note.id);
        },
      );
    }

    final checklist = bookmark.checklist!;

    return ChecklistCard(
      checklist: checklist,

      totalCount: checklistProvider.totalCount(
        checklist.id,
      ),

      checkedCount: checklistProvider.checkedCount(
        checklist.id,
      ),

      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChecklistDetailScreen(
              checklistId: checklist.id,
            ),
          ),
        );
      },

      onRename: () {
        ChecklistDialogs.promptRename(
          context,
          checklist.id,
          checklist.name,
        );
      },

      onDelete: () {
        checklistProvider.deleteChecklist(
          checklist.id,
        );
      },

      onBookmarkTap: () {
        checklistProvider.toggleBookmark(
          checklist.id,
        );
      },

      onShareTap: () {
        // TODO: Share checklist
      },
    );
  }
}

enum BookmarkType {
  note,
  checklist,
}

class BookmarkItem {
  final BookmarkType type;
  final DateTime updatedAt;

  final Note? note;
  final Checklist? checklist;

  BookmarkItem.fromNote(Note value)
      : type = BookmarkType.note,
        note = value,
        checklist = null,
        updatedAt = value.updatedAt;

  BookmarkItem.fromChecklist(Checklist value)
      : type = BookmarkType.checklist,
        note = null,
        checklist = value,
        updatedAt = value.updatedAt;
}

class _EmptyBookmarks extends StatelessWidget {
  const _EmptyBookmarks();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_outline,
                color: colors.onPrimary,
                size: 30,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'No bookmarks yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Bookmark notes and checklists to quickly access them here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}