import 'package:flutter/material.dart';
import 'package:notepad/providers/notes_provider.dart';
import 'package:notepad/screens/note_edit_screen.dart';
import 'package:notepad/widgets/note_card.dart';
import 'package:provider/provider.dart';

class NotesList extends StatelessWidget {
  final bool bookmarkedOnly;

  const NotesList({required this.bookmarkedOnly});

  @override
  Widget build(BuildContext context) {    
    final themeColor = Theme.of(context).colorScheme;

    return Consumer<NotesProvider>(
      builder: (context, provider, _) {
        final notes = bookmarkedOnly
            ? provider.bookmarkedNotes
            : provider.filteredNotes;

        if (notes.isEmpty) {
          final query = provider.searchQuery;
          String title;
          String description;

          if (bookmarkedOnly) {
            title = 'No bookmarked notes';
            description = 'Bookmark a note to save it here for quick access.';
          } else if (query.isNotEmpty) {
            title = 'No notes found';
            description = 'Try searching with a different keyword.';
          } else {
            title = 'No notes yet';
            description = 'Create notes to write down your thoughts, ideas, and anything you want to remember.';
          }

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
                      bookmarkedOnly
                          ? Icons.bookmark_outline
                          : query.isNotEmpty
                              ? Icons.search
                              : Icons.note_alt_outlined,
                      color: colors.onPrimary,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

      return ListView(
        padding: const EdgeInsets.all(28),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (int i = 0; i < notes.length; i++) ...[
                  NoteCard(
                    note: notes[i],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NoteEditScreen(note: notes[i]),
                        ),
                      );
                    },
                    onBookmarkTap: () {
                      provider.toggleBookmark(notes[i].id);
                    },
                    onShareTap: () {
                      // Share note
                    },
                    onDeleteTap: () {
                      provider.deleteNote(notes[i].id);
                    },
                  ),

                  if (i < notes.length - 1)
                    Divider(
                      height: 0.5,
                      thickness: 0.25,
                      color: themeColor.onSecondary,
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
}