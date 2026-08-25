import 'package:flutter/material.dart';
import 'package:notepad/services/share_service.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/notes_provider.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note;

  const NoteEditScreen({super.key, this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isSaving = false;
  bool _hasPendingSave = false;

  bool _isBookmarked = false;
  String? _autoSavedNoteId;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.note?.title ?? '');

    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );

    _isBookmarked = widget.note?.isBookmarked ?? false;
    _titleController.addListener(_autoSave);
    _contentController.addListener(_autoSave);
  }

  @override
  void dispose() {
    _titleController.removeListener(_autoSave);
    _contentController.removeListener(_autoSave);

    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _autoSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text;

    if (title.isEmpty && content.trim().isEmpty) {
      return;
    }

    if (_isSaving) {
      _hasPendingSave = true;
      return;
    }

    _isSaving = true;

    try {
      final provider = context.read<NotesProvider>();

      final finalTitle = title.isEmpty ? 'Untitled' : title;

      if (_isEditing) {
        await provider.updateNote(
          widget.note!.id,
          title: finalTitle,
          content: content,
          isBookmarked: _isBookmarked,
        );
      } else {
        if (_autoSavedNoteId == null) {
          final note = await provider.createNote(
            title: finalTitle,
            content: content,
            isBookmarked: _isBookmarked,
          );

          _autoSavedNoteId = note.id;
        } else {
          await provider.updateNote(
            _autoSavedNoteId!,
            title: finalTitle,
            content: content,
            isBookmarked: _isBookmarked,
          );
        }
      }
    } finally {
      _isSaving = false;

      if (_hasPendingSave) {
        _hasPendingSave = false;
        _autoSave();
      }
    }
  }

  void _delete() {
    if (!_isEditing) return;

    context.read<NotesProvider>().deleteNote(widget.note!.id);

    Navigator.of(context).pop();
  }

  Future<void> _shareNote() async {
    final noteId = _isEditing ? widget.note!.id : _autoSavedNoteId;

    if (noteId == null) return;
    final note = context.read<NotesProvider>().getNote(noteId);

    if (note == null) return;
    await ShareService.shareNote(note);
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? themeColors.primary : null,
            ),
            tooltip: 'Bookmark',
            onPressed: () {
              final noteId = _isEditing ? widget.note!.id : _autoSavedNoteId;

              if (noteId == null) return;
              context.read<NotesProvider>().toggleBookmark(noteId);

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
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: _shareNote,
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(10),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            children: [
              TextField(
                controller: _titleController,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),

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
      ),
    );
  }
}
