import 'package:flutter/material.dart';
import 'package:notepad/utils/hive_keys.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';

class NotesProvider extends ChangeNotifier {
  static const Uuid _uuid = Uuid();
  final notesBox = HiveKeys.notesBox;

  List<Note> get allNotes {
    final list = notesBox.values.toList();

    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return list;
  }

  List<Note> get bookmarkedNotes {
    final list = notesBox.values
        .where((note) => note.isBookmarked)
        .toList();

    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return list;
  }

  Future<Note> createNote({
    required String title,
    required String content,
    bool isBookmarked = false,
  }) async {
    final now = DateTime.now();

    final note = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      isBookmarked: isBookmarked,
    );

    await notesBox.put(note.id, note);

    notifyListeners();

    return note;
  }

  Future<void> updateNote(
    String id, {
    String? title,
    String? content,
    bool? isBookmarked,
  }) async {
    final note = notesBox.get(id);
    if (note == null) return;

    final updated = note.copyWith(
      title: title,
      content: content,
      updatedAt: DateTime.now(),
      isBookmarked: isBookmarked,
    );

    await notesBox.put(id, updated);

    notifyListeners();
  }

  Future<void> toggleBookmark(String id) async {
    final note = notesBox.get(id);

    if (note == null) return;

    final updated = note.copyWith(
      isBookmarked: !note.isBookmarked,
      updatedAt: DateTime.now(),
    );

    await notesBox.put(id, updated);

    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await notesBox.delete(id);

    notifyListeners();
  }
}
