import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notes_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/note_card.dart';
import 'grocery_screen.dart';
import 'note_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0; // 0 = Notes, 1 = Bookmarks, 2 = Groceries
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() => _isSearching = true);
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    context.read<NotesProvider>().setSearchQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isNotesTab = _tabIndex == 0 || _tabIndex == 1;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search notes by title...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 18),
                onChanged: (value) =>
                    context.read<NotesProvider>().setSearchQuery(value),
              )
            : Text(_titleForTab(_tabIndex)),
        actions: [
          if (isNotesTab)
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: _isSearching ? _stopSearch : _startSearch,
            ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: 'Toggle theme',
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _NotesList(bookmarkedOnly: false),
          _NotesList(bookmarkedOnly: true),
          const GroceryScreen(),
        ],
      ),
      floatingActionButton: isNotesTab
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NoteEditScreen()),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) {
          setState(() => _tabIndex = index);
          if (index == 2) _stopSearch();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Groceries',
          ),
        ],
      ),
    );
  }

  String _titleForTab(int index) {
    switch (index) {
      case 1:
        return 'Bookmarks';
      case 2:
        return 'Groceries';
      default:
        return 'Notes';
    }
  }
}

class _NotesList extends StatelessWidget {
  final bool bookmarkedOnly;

  const _NotesList({required this.bookmarkedOnly});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, provider, _) {
        final notes = bookmarkedOnly
            ? provider.bookmarkedNotes
            : provider.filteredNotes;

        if (notes.isEmpty) {
          final query = provider.searchQuery;
          String message;
          if (bookmarkedOnly) {
            message = 'No bookmarked notes yet.\nTap the bookmark icon on a note to save it here.';
          } else if (query.isNotEmpty) {
            message = 'No notes found for "$query"';
          } else {
            message = 'No notes yet.\nTap + to create your first note!';
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 88),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return NoteCard(
              note: note,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NoteEditScreen(note: note),
                ),
              ),
              onBookmarkTap: () => provider.toggleBookmark(note.id),
            );
          },
        );
      },
    );
  }
}
