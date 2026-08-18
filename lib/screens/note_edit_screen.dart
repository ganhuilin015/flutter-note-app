import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/notes_provider.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note; // null when creating a new note

  const NoteEditScreen({
    super.key,
    this.note,
  });

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool _isBookmarked = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.note?.title ?? '',
    );

    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );

    _isBookmarked = widget.note?.isBookmarked ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Don't save completely empty notes.
    if (title.isEmpty && content.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final provider = context.read<NotesProvider>();

    if (_isEditing) {
      provider.updateNote(
        widget.note!.id,
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        isBookmarked: _isBookmarked,
      );
    } else {
      provider.createNote(
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        isBookmarked: _isBookmarked,
      );
    }

    Navigator.of(context).pop();
  }

  void _delete() {
    if (!_isEditing) return;

    context.read<NotesProvider>().deleteNote(
      widget.note!.id,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Note' : 'New Note',
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked
                  ? Icons.bookmark
                  : Icons.bookmark_border,
            ),
            tooltip: 'Bookmark',
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
            },
          ),

          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: _delete,
            ),

          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.titleLarge,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const Divider(height: 24),

            TextField(
              controller: _contentController,
              maxLines: null,
              minLines: 8,
              decoration: const InputDecoration(
                hintText: 'Start writing...',
                border: InputBorder.none,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }
}