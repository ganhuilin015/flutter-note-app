import 'package:flutter/material.dart';
import 'package:notepad/providers/search_provider.dart';
import 'package:notepad/services/share_service.dart';
import 'package:notepad/widgets/empty_state.dart';
import 'package:notepad/widgets/floating_action.dart';
import 'package:provider/provider.dart';

import '../providers/checklist_provider.dart';
import '../widgets/checklist_card.dart';
import 'checklist_detail_screen.dart';

class ChecklistsScreen extends StatelessWidget {
  const ChecklistsScreen({super.key});

  Future<void> _createChecklist(BuildContext context) async {
    final checklist = await context.read<ChecklistProvider>().addChecklist('');

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChecklistDetailScreen(checklistId: checklist.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChecklistProvider, SearchProvider>(
      builder: (context, checklistProvider, searchProvider, _) {
        final query = searchProvider.query;
        final checklists = query.isEmpty
            ? List.of(checklistProvider.checklists)
            : checklistProvider.checklists.where((checklist) {
                return checklist.name.toLowerCase().contains(query);
              }).toList();

        late Widget content;

        if (checklists.isEmpty) {
          String title;
          String description;
          IconData icon;

          if (query.isNotEmpty) {
            title = 'No checklists found';
            description = 'Try searching with a different keyword.';
            icon = Icons.search;
          } else {
            title = 'No checklists yet';
            description = 'Create a checklist to keep track of groceries, tasks, packing lists, and more.';
            icon = Icons.checklist_outlined;
          }

          content = EmptyState(
            title: title,
            description: description,
            icon: icon,
          );
        } else {
          content = ListView(
            padding: const EdgeInsets.all(28),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (int i = 0; i < checklists.length; i++) ...[
                      ChecklistCard(
                        checklist: checklists[i],
                        totalCount: checklistProvider.totalCount(
                          checklists[i].id,
                        ),
                        checkedCount: checklistProvider.checkedCount(
                          checklists[i].id,
                        ),

                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChecklistDetailScreen(
                                checklistId: checklists[i].id,
                              ),
                            ),
                          );
                        },

                        onDelete: () {
                          checklistProvider.deleteChecklist(checklists[i].id);
                        },

                        onBookmarkTap: () {
                          checklistProvider.toggleBookmark(checklists[i].id);
                        },

                        onShareTap: () async {
                          final items = checklistProvider.blocks(
                            checklists[i].id,
                          );

                          await ShareService.shareChecklist(
                            checklists[i],
                            items,
                          );
                        },
                      ),

                      if (i < checklists.length - 1)
                        Divider(
                          height: 0.5,
                          thickness: 0.25,
                          color: Theme.of(context).colorScheme.onSecondary,
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
            tag: 'add_checklist',
            onPressed: () => _createChecklist(context),
          ),
        );
      },
    );
  }
}
