import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/reminder.dart';
import '../providers/reminder_provider.dart';

class ReminderEditScreen extends StatefulWidget {
  final Reminder? reminder; // null when creating a new reminder

  const ReminderEditScreen({super.key, this.reminder});

  @override
  State<ReminderEditScreen> createState() => _ReminderEditScreenState();
}

class _ReminderEditScreenState extends State<ReminderEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late DateTime _dateTime;

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.reminder?.title ?? '');
    _descController =
        TextEditingController(text: widget.reminder?.description ?? '');
    _dateTime = widget.reminder?.dateTime ??
        DateTime.now().add(const Duration(hours: 1));
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
      initialDate: _dateTime.isBefore(now) ? now : _dateTime,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
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
      initialTime: TimeOfDay.fromDateTime(_dateTime),
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
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    if (_dateTime.isBefore(DateTime.now())) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Date is in the past'),
          content: const Text(
            'This reminder time has already passed, so no notification will be scheduled. Save anyway?',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save anyway')),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final provider = context.read<ReminderProvider>();
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
    if (mounted) Navigator.of(context).pop();
  }

  void _delete() {
    if (!_isEditing) return;
    context.read<ReminderProvider>().deleteReminder(widget.reminder!.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Reminder' : 'New Reminder'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: _delete,
            ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.titleLarge,
              decoration: const InputDecoration(
                hintText: 'Reminder title',
                border: InputBorder.none,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const Divider(height: 24),
            TextField(
              controller: _descController,
              maxLines: null,
              minLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add a note (optional)...',
                border: InputBorder.none,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const Divider(height: 32),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(DateFormat('EEE, MMM d, yyyy').format(_dateTime)),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Time'),
                subtitle: Text(DateFormat('h:mm a').format(_dateTime)),
                onTap: _pickTime,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'You\'ll get a notification at this date and time.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
