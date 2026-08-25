import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/reminder.dart';
import '../providers/reminder_provider.dart';

class ReminderEditScreen extends StatefulWidget {
  final Reminder? reminder;

  const ReminderEditScreen({
    super.key,
    this.reminder,
  });

  @override
  State<ReminderEditScreen> createState() =>
      _ReminderEditScreenState();
}

class _ReminderEditScreenState extends State<ReminderEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late DateTime _dateTime;

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.reminder?.title ?? '',
    );

    _descController = TextEditingController(
      text: widget.reminder?.description ?? '',
    );

    _dateTime = widget.reminder?.dateTime ??
        DateTime.now().add(
          const Duration(hours: 1),
        );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime.isBefore(now)
          ? now
          : _dateTime,
      firstDate: now,
      lastDate: now.add(
        const Duration(days: 365 * 5),
      ),
    );

    if (date == null) return;

    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        _dateTime.hour,
        _dateTime.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _dateTime,
      ),
    );

    if (time == null) return;

    setState(() {
      _dateTime = DateTime(
        _dateTime.year,
        _dateTime.month,
        _dateTime.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
        ),
      );
      return;
    }

    if (_dateTime.isBefore(DateTime.now())) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text(
              'Date is in the past',
            ),
            content: const Text(
              'This reminder time has already passed, '
              'so no notification will be scheduled. '
              'Save anyway?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
                child: const Text('Save anyway'),
              ),
            ],
          );
        },
      );

      if (proceed != true) return;
    }

    final provider =
        context.read<ReminderProvider>();

    if (_isEditing) {
      await provider.updateReminder(
        widget.reminder!.id,
        title: title,
        description: _descController.text.trim(),
        dateTime: _dateTime,
      );
    } else {
      await provider.addReminder(
        title: title,
        description: _descController.text.trim(),
        dateTime: _dateTime,
      );
    }

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  void _delete() {
    if (!_isEditing) return;

    context
        .read<ReminderProvider>()
        .deleteReminder(widget.reminder!.id);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
              ),
              tooltip: 'Delete',
              onPressed: _delete,
            ),

          IconButton(
            icon: const Icon(
              Icons.check,
            ),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
            ),
            children: [

              TextField(
                controller: _titleController,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                ),
                textCapitalization:
                    TextCapitalization.sentences,
              ),

              TextField(
                controller: _descController,
                maxLines: null,
                minLines: 8,
                keyboardType:
                    TextInputType.multiline,
                textInputAction:
                    TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Start writing...',
                  border: InputBorder.none,
                ),
                textCapitalization:
                    TextCapitalization.sentences,
              ),

              const SizedBox(height: 24),

              InkWell(
                borderRadius:
                    BorderRadius.circular(12),
                onTap: _pickDate,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: colors.onSurfaceVariant,
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: theme
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: colors
                                    .onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              DateFormat(
                                'EEE, MMM d, yyyy',
                              ).format(_dateTime),
                              style: theme
                                  .textTheme
                                  .bodyLarge,
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.chevron_right,
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(),

              InkWell(
                borderRadius:
                    BorderRadius.circular(12),
                onTap: _pickTime,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        color: colors.onSurfaceVariant,
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Time',
                              style: theme
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: colors
                                    .onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              DateFormat(
                                'h:mm a',
                              ).format(_dateTime),
                              style: theme
                                  .textTheme
                                  .bodyLarge,
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.chevron_right,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You\'ll get a notification at this date and time.',
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color:
                              colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}