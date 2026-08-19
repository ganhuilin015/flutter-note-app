import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/checklist_provider.dart';
import '../widgets/checklist_card.dart';
import 'checklist_detail_screen.dart';

class ChecklistsScreen extends StatelessWidget {
  const ChecklistsScreen({super.key});

  Future<void> _promptNewChecklist(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New checklist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'e.g. Packing List'),
          onSubmitted: (value) => Navigator.pop(ctx, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    final checklist = await context.read<ChecklistProvider>().addChecklist(name);
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChecklistDetailScreen(checklistId: checklist.id),
      ),
    );
  }

  Future<void> _promptRename(BuildContext context, String id, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename checklist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (value) => Navigator.pop(ctx, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    context.read<ChecklistProvider>().renameChecklist(id, name);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChecklistProvider>(
      builder: (context, provider, _) {
        final checklists = provider.checklists;

        return Scaffold(
          body: checklists.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No checklists yet.\nTap + to create your first one!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 88),
                  itemCount: checklists.length,
                  itemBuilder: (context, index) {
                    final checklist = checklists[index];
                    return ChecklistCard(
                      checklist: checklist,
                      totalCount: provider.totalCount(checklist.id),
                      checkedCount: provider.checkedCount(checklist.id),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChecklistDetailScreen(
                            checklistId: checklist.id,
                          ),
                        ),
                      ),
                      onRename: () =>
                          _promptRename(context, checklist.id, checklist.name),
                      onDelete: () =>
                          provider.deleteChecklist(checklist.id),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _promptNewChecklist(context),
            tooltip: 'New checklist',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
