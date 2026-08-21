import 'package:flutter/material.dart';
import 'package:notepad/models/checklist.dart';
import 'package:notepad/models/checklist_item.dart';
import 'package:notepad/models/note.dart';
import 'package:notepad/models/reminder.dart';
import 'package:notepad/providers/search_provider.dart';
import 'package:notepad/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'providers/notes_provider.dart';
import 'providers/checklist_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();

  await Hive.initFlutter();
  Hive.registerAdapter(ChecklistAdapter());
  Hive.registerAdapter(ChecklistItemAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(ReminderAdapter());

  await Hive.openBox<Checklist>('checklists');
  await Hive.openBox<Note>('notes');
  await Hive.openBox<Reminder>('reminders');
  await Hive.openBox<ChecklistItem>('checklist_items');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()..resyncAll()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Notes',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
