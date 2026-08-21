import 'package:flutter/material.dart';
import 'package:notepad/providers/notes_provider.dart';
import 'package:notepad/providers/search_provider.dart';
import 'package:notepad/screens/note_edit_screen.dart';
import 'package:notepad/widgets/floating_action.dart';
import 'package:notepad/widgets/note_card.dart';
import 'package:provider/provider.dart';

class NotesList extends StatelessWidget {
  const NotesList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Consumer2<NotesProvider, SearchProvider>(
      builder: (context, notesProvider, searchProvider, _) {
        final query = searchProvider.query;
        final notes = query.isEmpty
          ? List.of(notesProvider.allNotes)
          : notesProvider.allNotes.where((note) {
              return note.title.toLowerCase().contains(query);
            }).toList();

        notes.sort(
          (a, b) => b.updatedAt.compareTo(a.updatedAt),
        );

        late Widget content;

        if (notes.isEmpty) {
          String title;
          String description;
          IconData icon;

          if (query.isNotEmpty) {
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
                    child: Icon(icon, color: colors.onPrimary, size: 30),
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
        } else {
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
                              builder: (_) => NoteEditScreen(note: notes[i]),
                            ),
                          );
                        },
                        onBookmarkTap: () {
                          notesProvider.toggleBookmark(notes[i].id);
                        },
                        onShareTap: () {
                          // TODO: Share note
                        },
                        onDeleteTap: () {
                          notesProvider.deleteNote(notes[i].id);
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
            tag: 'add_note',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const NoteEditScreen()));
            },
          ),
        );
      },
    );
  }
}
