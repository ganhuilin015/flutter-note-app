import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/reminder.dart';

class ReminderTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onTap;
  final ValueChanged<bool?> onToggleCompleted;
  final VoidCallback onDelete;

  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onTap,
    required this.onToggleCompleted,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = !reminder.isCompleted && reminder.isPast;

    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: theme.colorScheme.errorContainer,
        child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          onTap: onTap,
          leading: Checkbox(
            value: reminder.isCompleted,
            onChanged: onToggleCompleted,
            shape: const CircleBorder(),
          ),
          title: Text(
            reminder.title.isEmpty ? 'Untitled reminder' : reminder.title,
            style: TextStyle(
              decoration:
                  reminder.isCompleted ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reminder.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 4),
                  child: Text(
                    reminder.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Row(
                children: [
                  Icon(
                    Icons.alarm,
                    size: 14,
                    color: isOverdue
                        ? theme.colorScheme.error
                        : theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('EEE, MMM d, yyyy · h:mm a')
                        .format(reminder.dateTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isOverdue
                          ? theme.colorScheme.error
                          : theme.colorScheme.secondary,
                      fontWeight:
                          isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 6),
                    Text(
                      '· overdue',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.error),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
