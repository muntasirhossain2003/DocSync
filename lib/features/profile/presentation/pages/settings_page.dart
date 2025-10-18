import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          ListTile(
            leading: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : themeMode == ThemeMode.light
                  ? Icons.light_mode
                  : Icons.brightness_auto,
            ),
            title: const Text('Theme'),
            subtitle: Text(
              themeMode == ThemeMode.dark
                  ? 'Dark'
                  : themeMode == ThemeMode.light
                  ? 'Light'
                  : 'System',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showThemeDialog(context, ref, themeMode);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Other Settings',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notification toggle
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification settings coming soon'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
