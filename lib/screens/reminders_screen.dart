import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reminder_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/floating_action.dart';
import '../widgets/reminder_tile.dart';
import 'reminder_edit_screen.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Consumer<ReminderProvider>(
      builder: (context, provider, _) {
        final overdue = provider.overdue;
        final upcoming = provider.upcoming;
        final completed = provider.completed;

        final hasReminders =
            overdue.isNotEmpty ||
            upcoming.isNotEmpty ||
            completed.isNotEmpty;

        late Widget content;

        final reminders = [
          ...upcoming,
          ...overdue,
          ...completed,
        ];

        if (!hasReminders) {
          content = const EmptyState(
            title: 'No reminders yet',
            description:
                'Create a reminder to keep track of things you need to do.',
            icon: Icons.notifications_none,
          );
        } else {
            content = ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (int i = 0; i < reminders.length; i++) ...[
                        _buildReminderTile(
                          context,
                          provider,
                          reminders[i],
                        ),

                        if (i < reminders.length - 1)
                          Divider(
                            height: 0.5,
                            thickness: 0.25,
                            color: colors.onSecondary,
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            );
        }

        return Scaffold(
          body: content,

          floatingActionButton: AppFloatingActionButton(
            tag: 'add_reminder',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ReminderEditScreen(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildReminderTile(
    BuildContext context,
    ReminderProvider provider,
    dynamic reminder,
  ) {
    return ReminderTile(
      reminder: reminder,

      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReminderEditScreen(
              reminder: reminder,
            ),
          ),
        );
      },

      onToggleCompleted: (_) {
        provider.toggleCompleted(reminder.id);
      },

      onDelete: () {
        provider.deleteReminder(reminder.id);
      },
    );
  }
}
