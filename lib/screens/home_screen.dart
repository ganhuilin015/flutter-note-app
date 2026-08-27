import 'package:flutter/material.dart';
import 'package:notepad/providers/search_provider.dart';
import 'package:notepad/screens/bookmarks_screen.dart';
import 'package:notepad/screens/notelist_screen.dart';
import 'package:notepad/screens/settings_screen.dart';
import 'package:notepad/widgets/banner_ad.dart';
import 'package:notepad/widgets/search_bar.dart';
import 'package:provider/provider.dart';
import 'checklists_screen.dart';

import 'reminders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0; // 0 = Notes, 1 = Checklist, 2 = Reminders, 3 = Bookmarks
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
    });
    context.read<SearchProvider>().clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? AppSearchBar(
                hintText: _searchHint(),
              )
            : Text(_titleForTab(_tabIndex)),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching
                  ? Icons.close
                  : Icons.search,
            ),
            onPressed: _isSearching
                ? _stopSearch
                : _startSearch,
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: IndexedStack(
        index: _tabIndex,
        children: [
          const NotesList(),
          const ChecklistsScreen(),
          const RemindersScreen(),
          const BookmarksScreen(),
        ],
      ),

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavigationBar(
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
                icon: Icon(Icons.checklist_outlined),
                selectedIcon: Icon(Icons.checklist),
                label: 'Checklists',
              ),
              NavigationDestination(
                icon: Icon(Icons.alarm_outlined),
                selectedIcon: Icon(Icons.alarm),
                label: 'Reminders',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_outline),
                selectedIcon: Icon(Icons.bookmark),
                label: 'Bookmarks',
              ),
            ],
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  String _titleForTab(int index) {
    switch (index) {
      case 1:
        return 'Checklists';
      case 2:
        return 'Reminders';
      case 3:
        return 'Bookmarks';
      default:
        return 'Notes';
    }
  }

  String _searchHint() {
    switch (_tabIndex) {
      case 0:
        return 'Search notes...';

      case 1:
        return 'Search checklists...';

      case 2:
        return 'Search reminders...';

      case 3:
        return 'Search bookmarks...';

      default:
        return 'Search...';
    }
  }
}
