import 'package:flutter/material.dart';

import '../models/grocery_item.dart';

class GroceryTile extends StatelessWidget {
  final GroceryItem item;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;

  const GroceryTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: theme.colorScheme.errorContainer,
        child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => onDelete(),
      child: CheckboxListTile(
        value: item.isChecked,
        onChanged: onToggle,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          item.name,
          style: TextStyle(
            decoration:
                item.isChecked ? TextDecoration.lineThrough : null,
            color: item.isChecked
                ? theme.textTheme.bodySmall?.color
                : theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: item.quantity.isNotEmpty ? Text(item.quantity) : null,
      ),
    );
  }
}
