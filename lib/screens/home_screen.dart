import 'package:flutter/material.dart';
import 'package:notepad/screens/notelist_screen.dart';
import 'package:notepad/widgets/floating_action.dart';
import 'package:provider/provider.dart';

import '../providers/notes_provider.dart';
import '../providers/theme_provider.dart';
import 'checklists_screen.dart';
import 'note_edit_screen.dart';
import 'reminder_edit_screen.dart';
import 'reminders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0; // 0 = Notes, 1 = Reminders, 2 = Checklist
  bool _isSearching = false;
  bool _showBookmarkedOnly = false;
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
    final isNotesTab = _tabIndex == 0;

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
          if (isNotesTab && !_isSearching)
            IconButton(
              icon: Icon(
                _showBookmarkedOnly ? Icons.bookmark : Icons.bookmark_border,
              ),
              tooltip: 'Show bookmarked only',
              onPressed: () =>
                  setState(() => _showBookmarkedOnly = !_showBookmarkedOnly),
            ),
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
          NotesList(bookmarkedOnly: _showBookmarkedOnly),
          const RemindersScreen(),
          const ChecklistsScreen(),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) {
          setState(() => _tabIndex = index);
          if (index != 0) _stopSearch();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.alarm_outlined),
            selectedIcon: Icon(Icons.alarm),
            label: 'Reminders',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Checklist',
          ),
        ],
      ),
    );
  }

  String _titleForTab(int index) {
    switch (index) {
      case 1:
        return 'Reminders';
      case 2:
        return 'Checklist';
      default:
        return _showBookmarkedOnly ? 'Bookmarked Notes' : 'Notes';
    }
  }
}
