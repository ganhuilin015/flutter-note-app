import 'package:flutter/material.dart';
import 'package:notepad/providers/notes_provider.dart';
import 'package:notepad/screens/note_edit_screen.dart';
import 'package:notepad/widgets/floating_action.dart';
import 'package:notepad/widgets/note_card.dart';
import 'package:provider/provider.dart';

class NotesList extends StatelessWidget {
  final bool bookmarkedOnly;

  const NotesList({
    super.key,
    required this.bookmarkedOnly,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Consumer<NotesProvider>(
      builder: (context, provider, _) {
        final notes = bookmarkedOnly
            ? provider.bookmarkedNotes
            : provider.filteredNotes;

        late Widget content;

        if (notes.isEmpty) {
          final query = provider.searchQuery;

          String title;
          String description;
          IconData icon;

          if (bookmarkedOnly) {
            title = 'No bookmarked notes';
            description =
                'Bookmark a note to save it here for quick access.';
            icon = Icons.bookmark_outline;
          } else if (query.isNotEmpty) {
            title = 'No notes found';
            description = 'Try searching with a different keyword.';
            icon = Icons.search;
          } else {
            title = 'No notes yet';
            description =
                'Create notes to write down your thoughts, ideas, and anything you want to remember.';
            icon = Icons.note_alt_outlined;
          }

          content = Center(
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
                      icon,
                      color: colors.onPrimary,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

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

        else {
          content = ListView(
            padding: const EdgeInsets.all(28),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
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
                              builder: (_) => NoteEditScreen(
                                note: notes[i],
                              ),
                            ),
                          );
                        },
                        onBookmarkTap: () {
                          provider.toggleBookmark(notes[i].id);
                        },
                        onShareTap: () {
                          // TODO: Share note
                        },
                        onDeleteTap: () {
                          provider.deleteNote(notes[i].id);
                        },
                      ),

                      if (i < notes.length - 1)
                        Divider(
                          height: 0.5,
                          thickness: 0.25,
                          color: colors.onSecondary,
                        ),
                    ],
                  ],
                ),
              ),
            ],
          );
        }

        return Scaffold(
          body: content,

          floatingActionButton: AppFloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NoteEditScreen(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}