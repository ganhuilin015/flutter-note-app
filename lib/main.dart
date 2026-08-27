import 'package:flutter/material.dart';
import 'package:notepad/models/checklist.dart';
import 'package:notepad/models/checklist_item.dart';
import 'package:notepad/models/note.dart';
import 'package:notepad/models/reminder.dart';
import 'package:notepad/providers/reminder_settings_provider.dart';
import 'package:notepad/providers/search_provider.dart';
import 'package:notepad/theme/app_theme.dart';
import 'package:notepad/utils/hive_keys.dart';
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

  await Hive.openBox<Checklist>(HiveKeys.checklistsBoxName);
  await Hive.openBox<Note>(HiveKeys.notesBoxName);
  await Hive.openBox<Reminder>(HiveKeys.remindersBoxName);
  await Hive.openBox<ChecklistItem>(HiveKeys.itemsBoxName);
  await Hive.openBox(HiveKeys.themeBoxName);
  await Hive.openBox(HiveKeys.reminderSettingsBoxName);

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
        ChangeNotifierProvider(
          create: (_) {
            final provider =ReminderSettingsProvider();
            provider.load();
            return provider;
          },
        ),

        ChangeNotifierProvider(
          create: (context) {
            return ReminderProvider(
              context.read<ReminderSettingsProvider>(),
            );
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'IncNote',
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
