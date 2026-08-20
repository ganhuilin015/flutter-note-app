import 'package:flutter/material.dart';
import 'package:notepad/widgets/floating_action.dart';
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
          decoration: const InputDecoration(
            hintText: 'e.g. Packing List',
          ),
          onSubmitted: (value) {
            Navigator.pop(ctx, value);
          },
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

    controller.dispose();

    if (name == null || name.trim().isEmpty || !context.mounted) {
      return;
    }

    final checklist =
        await context.read<ChecklistProvider>().addChecklist(name);

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChecklistDetailScreen(
          checklistId: checklist.id,
        ),
      ),
    );
  }

  Future<void> _promptRename(
    BuildContext context,
    String id,
    String currentName,
  ) async {
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

    controller.dispose();

    if (name == null || name.trim().isEmpty || !context.mounted) {
      return;
    }

    await context.read<ChecklistProvider>().renameChecklist(id, name);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChecklistProvider>(
      builder: (context, provider, _) {
        final checklists = provider.checklists;

        late Widget content;

        if (checklists.isEmpty) {
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
                      Icons.checklist_outlined,
                      color: colors.onPrimary,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'No checklists yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Create a checklist to keep track of groceries, tasks, packing lists, and more.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        else {
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
                    for (int i = 0; i < checklists.length; i++) ...[
                      ChecklistCard(
                        checklist: checklists[i],
                        totalCount:
                            provider.totalCount(checklists[i].id),
                        checkedCount:
                            provider.checkedCount(checklists[i].id),

                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChecklistDetailScreen(
                                checklistId: checklists[i].id,
                              ),
                            ),
                          );
                        },

                        onRename: () {
                          _promptRename(
                            context,
                            checklists[i].id,
                            checklists[i].name,
                          );
                        },

                        onDelete: () {
                          provider.deleteChecklist(checklists[i].id);
                        },

                        onBookmarkTap: () {
                          provider.toggleBookmark(checklists[i].id);
                        },

                        onShareTap: () {
                          // TODO: implement sharing
                        },
                      ),

                      if (i < checklists.length - 1)
                        Divider(
                          height: 0.5,
                          thickness: 0.25,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondary,
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
            onPressed: () => _promptNewChecklist(context),
          ),
        );
      },
    );
  }
}