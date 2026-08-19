import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reminder_provider.dart';
import '../widgets/reminder_tile.dart';
import 'reminder_edit_screen.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, provider, _) {
        final overdue = provider.overdue;
        final upcoming = provider.upcoming;
        final completed = provider.completed;

        if (overdue.isEmpty && upcoming.isEmpty && completed.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No reminders yet.\nTap + to set your first reminder!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 88),
          children: [
            if (overdue.isNotEmpty) ...[
              _SectionHeader(label: 'Overdue', color: Theme.of(context).colorScheme.error),
              ...overdue.map((r) => ReminderTile(
                    reminder: r,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReminderEditScreen(reminder: r),
                      ),
                    ),
                    onToggleCompleted: (_) => provider.toggleCompleted(r.id),
                    onDelete: () => provider.deleteReminder(r.id),
                  )),
            ],
            if (upcoming.isNotEmpty) ...[
              const _SectionHeader(label: 'Upcoming'),
              ...upcoming.map((r) => ReminderTile(
                    reminder: r,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReminderEditScreen(reminder: r),
                      ),
                    ),
                    onToggleCompleted: (_) => provider.toggleCompleted(r.id),
                    onDelete: () => provider.deleteReminder(r.id),
                  )),
            ],
            if (completed.isNotEmpty) ...[
              const _SectionHeader(label: 'Completed'),
              ...completed.map((r) => ReminderTile(
                    reminder: r,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReminderEditScreen(reminder: r),
                      ),
                    ),
                    onToggleCompleted: (_) => provider.toggleCompleted(r.id),
                    onDelete: () => provider.deleteReminder(r.id),
                  )),
            ],
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color? color;

  const _SectionHeader({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
