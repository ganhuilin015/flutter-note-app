import 'package:flutter/material.dart';
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

  void _autoSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text;

    if (title.isEmpty && content.trim().isEmpty) {
      return;
    }

    final provider = context.read<NotesProvider>();

    final finalTitle = title.isEmpty ? 'Untitled' : title;

    if (_isEditing) {
      provider.updateNote(
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
        provider.updateNote(
          _autoSavedNoteId!,
          title: finalTitle,
          content: content,
          isBookmarked: _isBookmarked,
        );
      }
    }
  }

  void _delete() {
    if (!_isEditing) return;

    context.read<NotesProvider>().deleteNote(widget.note!.id);

    Navigator.of(context).pop();
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
              final noteId = _isEditing
                ? widget.note!.id
                : _autoSavedNoteId;

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
            onPressed: () {
              //TODO: share function
            },
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
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
