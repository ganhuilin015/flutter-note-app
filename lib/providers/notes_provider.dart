import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';

class NotesProvider extends ChangeNotifier {
  static const String _prefsKey = 'notes_data';
  static const Uuid _uuid = Uuid();

  List<Note> _notes = [];
  String _searchQuery = '';

  List<Note> get allNotes => List.unmodifiable(_notes);

  String get searchQuery => _searchQuery;

  List<Note> get filteredNotes {
    final query = _searchQuery.trim().toLowerCase();

    final list = query.isEmpty
        ? List<Note>.from(_notes)
        : _notes
            .where(
              (note) => note.title.toLowerCase().contains(query),
            )
            .toList();

    list.sort(
      (a, b) => b.updatedAt.compareTo(a.updatedAt),
    );

    return list;
  }

  List<Note> get bookmarkedNotes {
    final list = _notes
        .where((note) => note.isBookmarked)
        .toList();

    list.sort(
      (a, b) => b.updatedAt.compareTo(a.updatedAt),
    );

    return list;
  }

  NotesProvider() {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final String? raw = prefs.getString(_prefsKey);

    if (raw != null && raw.isNotEmpty) {
      final List decoded = jsonDecode(raw) as List;

      _notes = decoded
          .map(
            (e) => Note.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();

    final String encoded = jsonEncode(
      _notes.map((note) => note.toJson()).toList(),
    );

    await prefs.setString(_prefsKey, encoded);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Note createNote({
    required String title,
    required String content,
    bool isBookmarked = false,
  }) {
    final now = DateTime.now();

    final note = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      isBookmarked: isBookmarked,
    );

    _notes.add(note);
    _persist();
    notifyListeners();
    
    return note;
  }

  Future<void> updateNote(
    String id, {
    String? title,
    String? content,
    bool? isBookmarked,
  }) async {
    final index = _notes.indexWhere(
      (note) => note.id == id,
    );

    if (index == -1) return;

    final updated = _notes[index].copyWith(
      title: title,
      content: content,
      updatedAt: DateTime.now(),
      isBookmarked: isBookmarked,
    );

    _notes[index] = updated;

    await _persist();

    notifyListeners();
  }

  Future<void> toggleBookmark(String id) async {
    final index = _notes.indexWhere(
      (note) => note.id == id,
    );

    if (index == -1) return;

    _notes[index] = _notes[index].copyWith(
      isBookmarked: !_notes[index].isBookmarked,
      updatedAt: DateTime.now(),
    );

    await _persist();

    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere(
      (note) => note.id == id,
    );

    await _persist();

    notifyListeners();
  }
}