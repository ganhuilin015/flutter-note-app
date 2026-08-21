import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/checklist_provider.dart';
import '../widgets/checklist_item_tile.dart';

class ChecklistDetailScreen extends StatefulWidget {
  final String checklistId;

  const ChecklistDetailScreen({super.key, required this.checklistId});

  @override
  State<ChecklistDetailScreen> createState() => _ChecklistDetailScreenState();
}

class _ChecklistDetailScreenState extends State<ChecklistDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _addItem(ChecklistProvider provider) {
    provider.addItem(
      widget.checklistId,
      _nameController.text,
      quantity: _qtyController.text,
    );
    _nameController.clear();
    _qtyController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChecklistProvider>(
      builder: (context, provider, _) {
        final checklist = provider.checklistById(widget.checklistId);

        if (checklist == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        final pending = provider.pendingItems(widget.checklistId);
        final checked = provider.checkedItems(widget.checklistId);
        final total = provider.totalCount(widget.checklistId);
        final done = provider.checkedCount(widget.checklistId);

        return Scaffold(
          appBar: AppBar(title: Text(checklist.name)),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Add an item...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _addItem(provider),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _qtyController,
                        decoration: const InputDecoration(
                          hintText: 'Qty (optional)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _addItem(provider),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      iconSize: 32,
                      onPressed: () => _addItem(provider),
                    ),
                  ],
                ),
              ),
              if (total > 0)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$done/$total done',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (checked.isNotEmpty)
                        TextButton(
                          onPressed: () =>
                              provider.clearChecked(widget.checklistId),
                          child: const Text('Clear checked'),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: (pending.isEmpty && checked.isEmpty)
                    ? Center(
                        child: Text(
                          'This checklist is empty.\nAdd something above!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView(
                        children: [
                          ...pending.map(
                            (item) => ChecklistItemTile(
                              item: item,
                              onToggle: (_) =>
                                  provider.toggleChecked(item.id),
                              onDelete: () => provider.deleteItem(item.id),
                            ),
                          ),
                          if (checked.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Checked',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            ...checked.map(
                              (item) => ChecklistItemTile(
                                item: item,
                                onToggle: (_) =>
                                    provider.toggleChecked(item.id),
                                onDelete: () => provider.deleteItem(item.id),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
