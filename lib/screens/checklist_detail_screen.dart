import 'package:flutter/material.dart';
import 'package:notepad/models/checklist_item.dart';
import 'package:provider/provider.dart';

import '../providers/checklist_provider.dart';

class ChecklistDetailScreen extends StatefulWidget {
  final String checklistId;

  const ChecklistDetailScreen({
    super.key,
    required this.checklistId,
  });

  @override
  State<ChecklistDetailScreen> createState() =>
      _ChecklistDetailScreenState();
}

class _ChecklistDetailScreenState extends State<ChecklistDetailScreen> {
  late final TextEditingController _titleController;

  String? _focusBlockId;

  @override
  void initState() {
    super.initState();

    final provider = context.read<ChecklistProvider>();
    final checklist = provider.checklistById(widget.checklistId);

    _titleController = TextEditingController(
      text: checklist?.name ?? '',
    );

    _titleController.addListener(_saveTitle);
  }

  @override
  void dispose() {
    _titleController.removeListener(_saveTitle);
    _titleController.dispose();
    super.dispose();
  }

  void _saveTitle() {
    context.read<ChecklistProvider>().renameChecklist(
          widget.checklistId,
          _titleController.text,
        );
  }

  Future<void> _saveBeforeExit() async {
    final title = _titleController.text.trim();

    await context.read<ChecklistProvider>().renameChecklist(
          widget.checklistId,
          title.isEmpty ? 'Untitled' : title,
        );
  }

  Future<void> _addTextBlock() async {
    final provider = context.read<ChecklistProvider>();

    final id = await provider.addTextBlock(
      widget.checklistId,
    );

    if (!mounted) return;

    setState(() {
      _focusBlockId = id;
    });
  }

  Future<void> _addCheckbox() async {
    final provider = context.read<ChecklistProvider>();

    final id = await provider.addCheckbox(
      widget.checklistId,
    );

    if (!mounted) return;

    setState(() {
      _focusBlockId = id;
    });
  }

  Future<void> _deleteChecklist() async {
    final provider = context.read<ChecklistProvider>();

    await provider.deleteChecklist(widget.checklistId);

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Consumer<ChecklistProvider>(
      builder: (context, provider, _) {
        final checklist = provider.checklistById(
          widget.checklistId,
        );

        if (checklist == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });

          return const Scaffold(
            body: SizedBox.shrink(),
          );
        }

        final blocks = provider.blocks(
          widget.checklistId,
        );

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            await _saveBeforeExit();

            if (!context.mounted) return;

            Navigator.of(context).pop();
          },
          child: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: Icon(
                    checklist.isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: checklist.isBookmarked
                        ? colors.primary
                        : null,
                  ),
                  tooltip: 'Bookmark',
                  onPressed: () {
                    provider.toggleBookmark(
                      widget.checklistId,
                    );
                  },
                ),

                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  tooltip: 'Delete',
                  onPressed: _deleteChecklist,
                ),

                IconButton(
                  icon: const Icon(
                    Icons.share,
                  ),
                  tooltip: 'Share',
                  onPressed: () {
                    // TODO: implement sharing
                  },
                ),
              ],
            ),

            body: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
              ),
              children: [

                TextField(
                  controller: _titleController,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                  textCapitalization:
                      TextCapitalization.sentences,
                ),

                const SizedBox(height: 10),

                if (blocks.isEmpty)
                  _EmptyEditor(
                    onAddText: _addTextBlock,
                    onAddCheckbox: _addCheckbox,
                  ),

                ...blocks.map(
                  (block) {
                    return _ChecklistBlockEditor(
                      key: ValueKey(block.id),

                      item: block,

                      autoFocus:
                          block.id == _focusBlockId,

                      onFocusHandled: () {
                        if (!mounted) return;

                        if (_focusBlockId == block.id) {
                          setState(() {
                            _focusBlockId = null;
                          });
                        }
                      },

                      onToggle: () {
                        provider.toggleChecked(
                          block.id,
                        );
                      },

                      onDelete: () {
                        provider.deleteItem(
                          block.id,
                        );
                      },

                      onChanged: (value) {
                        provider.updateBlock(
                          block.id,
                          name: value,
                        );
                      },

                      onAddCheckbox: _addCheckbox,
                    );
                  },
                ),

                const SizedBox(height: 120),
              ],
            ),

            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.text_fields,
                      ),
                      tooltip: 'Add text',
                      onPressed: _addTextBlock,
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.check_box_outlined,
                      ),
                      tooltip: 'Add checklist item',
                      onPressed: _addCheckbox,
                    ),

                    const Spacer(),

                    Text(
                      '${provider.checkedCount(widget.checklistId)} / '
                      '${provider.totalCount(widget.checklistId)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


class _EmptyEditor extends StatelessWidget {
  final VoidCallback onAddText;
  final VoidCallback onAddCheckbox;

  const _EmptyEditor({
    required this.onAddText,
    required this.onAddCheckbox,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: onAddText,
            icon: const Icon(
              Icons.text_fields,
            ),
            label: const Text(
              'Start writing',
            ),
          ),

          const SizedBox(width: 8),

          TextButton.icon(
            onPressed: onAddCheckbox,
            icon: const Icon(
              Icons.check_box_outlined,
            ),
            label: const Text(
              'Add checklist',
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistBlockEditor extends StatefulWidget {
  final ChecklistItem item;

  final bool autoFocus;

  final VoidCallback onFocusHandled;

  final VoidCallback onToggle;

  final VoidCallback onDelete;

  final ValueChanged<String> onChanged;

  final VoidCallback onAddCheckbox;

  const _ChecklistBlockEditor({
    super.key,
    required this.item,
    required this.autoFocus,
    required this.onFocusHandled,
    required this.onToggle,
    required this.onDelete,
    required this.onChanged,
    required this.onAddCheckbox,
  });

  @override
  State<_ChecklistBlockEditor> createState() =>
      _ChecklistBlockEditorState();
}

class _ChecklistBlockEditorState
    extends State<_ChecklistBlockEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.item.name,
    );

    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (widget.autoFocus) {
        _focusNode.requestFocus();

        widget.onFocusHandled();
      }
    });
  }

  @override
  void didUpdateWidget(
    covariant _ChecklistBlockEditor oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.item.name != _controller.text) {
      final selection = _controller.selection;

      final newLength = widget.item.name.length;

      int clampOffset(int offset) {
        return offset.clamp(0, newLength);
      }

      _controller.value = TextEditingValue(
        text: widget.item.name,
        selection: selection.copyWith(
          baseOffset: clampOffset(
            selection.baseOffset,
          ),
          extentOffset: clampOffset(
            selection.extentOffset,
          ),
        ),
      );
    }

    // Focus newly created block.
    if (!oldWidget.autoFocus &&
        widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _focusNode.requestFocus();

        widget.onFocusHandled();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (!widget.item.isCheckbox) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,

          keyboardType: TextInputType.multiline,

          textInputAction:
              TextInputAction.newline,

          minLines: 1,
          maxLines: null,

          decoration: const InputDecoration(
            hintText: 'Start writing...',
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),

          textCapitalization:
              TextCapitalization.sentences,

          onChanged: widget.onChanged,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: widget.item.isChecked,
            onChanged: (_) {
              widget.onToggle();
            },

            visualDensity:
                VisualDensity.compact,

            materialTapTargetSize:
                MaterialTapTargetSize.shrinkWrap,
          ),

          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,

              keyboardType:
                  TextInputType.text,

              textInputAction:
                  TextInputAction.next,

              decoration:
                  const InputDecoration(
                hintText: 'List item',
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    EdgeInsets.zero,
              ),

              textCapitalization:
                  TextCapitalization.sentences,

              onChanged: widget.onChanged,

              onSubmitted: (_) {
                widget.onAddCheckbox();
              },
            ),
          ),

          IconButton(
            icon: const Icon(
              Icons.close,
              size: 18,
            ),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}