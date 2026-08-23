import 'package:flutter/material.dart';
import 'package:notepad/providers/theme_provider.dart';
import 'package:notepad/services/permission_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final themeColor = Theme.of(context).colorScheme;
    final isDark = theme.isDarkMode;

    Future<void> openPrivacy() async {
      final url = Uri.parse('https://ganhuilin015.github.io/timer-legal/');
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }

    Future<void> openTOS() async {
      final url = Uri.parse(
        'https://ganhuilin015.github.io/timer-legal/tos.html',
      );
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Appearance'),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            color: themeColor.secondary,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                  title: Text(isDark ? 'Dark Mode' : 'Light Mode'),
                  onTap: () {
                    theme.toggleTheme(!isDark);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _sectionTitle('Permissions'),

          Card(
            elevation: 0,
            color: themeColor.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: FutureBuilder(
              future: Future.wait([PermissionService.isNotificationGranted()]),
              builder: (context, snapshot) {
                final notifGranted = snapshot.data?[0] ?? false;

                return Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        notifGranted
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: themeColor.onSecondary,
                      ),
                      title: const Text('Notifications'),
                      subtitle: Text(notifGranted ? 'Enabled' : 'Disabled'),
                    ),

                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Open App Settings'),
                      subtitle: const Text('Manage permissions'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => PermissionService.openSettings(),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          _sectionTitle('Legal'),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            color: themeColor.secondary,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: openTOS,
                ),
              ],
            ),
          ),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            color: themeColor.secondary,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: openPrivacy,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.grey,
        ),
      ),
    );
  }
}
