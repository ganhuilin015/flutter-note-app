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
    final colors = theme.colorScheme;

    final isOverdue =
        !reminder.isCompleted && reminder.isPast;

    return Dismissible(
      key: ValueKey(reminder.id),

      direction: DismissDirection.endToStart,

      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        color: colors.errorContainer,
        child: Icon(
          Icons.delete,
          color: colors.onErrorContainer,
        ),
      ),

      onDismissed: (_) => onDelete(),

      child: Container(
        color: colors.secondary,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: 1.3,
                  child: Checkbox(
                    value: reminder.isCompleted,
                    onChanged: onToggleCompleted,
                    shape: const CircleBorder(),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.onSecondary,
                      width: 1,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (reminder.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            reminder.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                              decoration: reminder.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.alarm,
                            size: 14,
                            color: isOverdue
                                ? colors.error
                                : colors.onSecondary,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            DateFormat(
                              'MMM d, yyyy · h:mm a',
                            ).format(reminder.dateTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isOverdue
                                  ? colors.error
                                  : colors.onSecondary,
                              fontWeight: isOverdue
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),

                          if (isOverdue) ...[
                            Text(
                              '· overdue',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}