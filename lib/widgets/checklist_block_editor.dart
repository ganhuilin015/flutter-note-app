import 'package:flutter/material.dart';
import 'package:notepad/models/checklist_item.dart';

class ChecklistBlockEditor extends StatefulWidget {

  final ChecklistItem item;
  final bool autoFocus;
  final VoidCallback onFocusHandled;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final ValueChanged<String> onChanged;
  final VoidCallback onAddCheckbox;

  const ChecklistBlockEditor({
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
  State<ChecklistBlockEditor> createState() =>
      _ChecklistBlockEditorState();
}

class _ChecklistBlockEditorState extends State<ChecklistBlockEditor> {
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
    covariant ChecklistBlockEditor oldWidget,
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
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),

          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              decoration:
                const InputDecoration(
                  hintText: 'List item',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),

              textCapitalization: TextCapitalization.sentences,
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