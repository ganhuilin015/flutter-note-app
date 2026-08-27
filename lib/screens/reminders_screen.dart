import 'package:flutter/material.dart';
import 'package:notepad/providers/search_provider.dart';
import 'package:notepad/widgets/native_ad.dart';
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

    return Consumer2<ReminderProvider, SearchProvider>(
      builder: (context, provider, searchProvider, _) {
        final query = searchProvider.query.trim().toLowerCase();

        final reminders = [
          ...provider.upcoming,
          ...provider.overdue,
          ...provider.completed,
        ];

        final filteredReminders = query.isEmpty
            ? List.of(reminders)
            : reminders.where((reminder) {
                return reminder.title.toLowerCase().contains(query) ||
                    reminder.description.toLowerCase().contains(query);
              }).toList();

        late Widget content;

        if (reminders.isEmpty) {
          content = const EmptyState(
            title: 'No reminders yet',
            description:
                'Create a reminder to keep track of things you need to do.',
            icon: Icons.notifications_none,
          );
        }
        else if (filteredReminders.isEmpty) {
          content = const EmptyState(
            title: 'No reminders found',
            description:
                'Try searching with a different keyword.',
            icon: Icons.search,
          );
        }

        else {
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
                    for (
                      int i = 0;
                      i < filteredReminders.length;
                      i++
                    ) ...[

                      if (i == 2 && filteredReminders.length >= 3)
                        const NativeAdWidget(),

                      _buildReminderTile(
                        context,
                        provider,
                        filteredReminders[i],
                      ),

                      if (i < filteredReminders.length - 1)
                        Divider(
                          height: 0.5,
                          thickness: 0.25,
                          color: colors.onSecondary,
                        ),
                    ],
                    
                    if (filteredReminders.length < 3)
                      const NativeAdWidget(),
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