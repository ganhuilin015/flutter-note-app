import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/grocery_provider.dart';
import '../widgets/grocery_tile.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _addItem() {
    final provider = context.read<GroceryProvider>();
    provider.addItem(_nameController.text, quantity: _qtyController.text);
    _nameController.clear();
    _qtyController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroceryProvider>(
      builder: (context, provider, _) {
        final pending = provider.pendingItems;
        final checked = provider.checkedItems;

        return Column(
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
                      onSubmitted: (_) => _addItem(),
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
                      onSubmitted: (_) => _addItem(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    iconSize: 32,
                    onPressed: _addItem,
                  ),
                ],
              ),
            ),
            if (provider.totalCount > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${provider.checkedCount}/${provider.totalCount} done',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (checked.isNotEmpty)
                      TextButton(
                        onPressed: () => provider.clearChecked(),
                        child: const Text('Clear checked'),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: (pending.isEmpty && checked.isEmpty)
                  ? Center(
                      child: Text(
                        'Your grocery list is empty.\nAdd something above!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView(
                      children: [
                        ...pending.map(
                          (item) => GroceryTile(
                            item: item,
                            onToggle: (_) => provider.toggleChecked(item.id),
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
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          ...checked.map(
                            (item) => GroceryTile(
                              item: item,
                              onToggle: (_) => provider.toggleChecked(item.id),
                              onDelete: () => provider.deleteItem(item.id),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
