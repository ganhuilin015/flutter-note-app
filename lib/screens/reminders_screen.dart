import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reminder_provider.dart';
import '../widgets/reminder_tile.dart';
import '../widgets/floating_action.dart';
import 'reminder_edit_screen.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  Future<void> _createReminder(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ReminderEditScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

        if (!hasReminders) {
          final theme = Theme.of(context);
          final colors = theme.colorScheme;

          content = Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none,
                      color: colors.onPrimary,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'No reminders yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Create a reminder to keep track of things you need to do.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        } else {
          content = ListView(
            padding: const EdgeInsets.all(28),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Overdue
                    if (overdue.isNotEmpty) ...[
                      const _SectionHeader(
                        label: 'Overdue',
                      ),

                      for (int i = 0; i < overdue.length; i++) ...[
                        ReminderTile(
                          reminder: overdue[i],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReminderEditScreen(
                                  reminder: overdue[i],
                                ),
                              ),
                            );
                          },
                          onToggleCompleted: (_) {
                            provider.toggleCompleted(
                              overdue[i].id,
                            );
                          },
                          onDelete: () {
                            provider.deleteReminder(
                              overdue[i].id,
                            );
                          },
                        ),

                        if (i < overdue.length - 1)
                          Divider(
                            height: 0.5,
                            thickness: 0.25,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondary,
                          ),
                      ],
                    ],

                    // Upcoming
                    if (upcoming.isNotEmpty) ...[
                      const _SectionHeader(
                        label: 'Upcoming',
                      ),

                      for (int i = 0; i < upcoming.length; i++) ...[
                        ReminderTile(
                          reminder: upcoming[i],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReminderEditScreen(
                                  reminder: upcoming[i],
                                ),
                              ),
                            );
                          },
                          onToggleCompleted: (_) {
                            provider.toggleCompleted(
                              upcoming[i].id,
                            );
                          },
                          onDelete: () {
                            provider.deleteReminder(
                              upcoming[i].id,
                            );
                          },
                        ),

                        if (i < upcoming.length - 1)
                          Divider(
                            height: 0.5,
                            thickness: 0.25,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondary,
                          ),
                      ],
                    ],

                    // Completed
                    if (completed.isNotEmpty) ...[
                      const _SectionHeader(
                        label: 'Completed',
                      ),

                      for (int i = 0; i < completed.length; i++) ...[
                        ReminderTile(
                          reminder: completed[i],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReminderEditScreen(
                                  reminder: completed[i],
                                ),
                              ),
                            );
                          },
                          onToggleCompleted: (_) {
                            provider.toggleCompleted(
                              completed[i].id,
                            );
                          },
                          onDelete: () {
                            provider.deleteReminder(
                              completed[i].id,
                            );
                          },
                        ),

                        if (i < completed.length - 1)
                          Divider(
                            height: 0.5,
                            thickness: 0.25,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondary,
                          ),
                      ],
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
            onPressed: () => _createReminder(context),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        8,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}