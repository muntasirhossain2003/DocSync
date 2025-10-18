import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const PatientShell({super.key, required this.navigationShell});

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const _PatientDrawer(),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        backgroundColor: isDark
            ? colorScheme.surface
            : colorScheme.secondaryContainer,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(
              FluentIcons.home_24_regular,
              color: colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              FluentIcons.home_24_filled,
              color: colorScheme.primary,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              FluentIcons.stethoscope_24_regular,
              color: colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              FluentIcons.stethoscope_24_filled,
              color: colorScheme.primary,
            ),
            label: 'Consult',
          ),
          NavigationDestination(
            icon: Icon(
              FluentIcons.brain_circuit_24_regular,
              color: colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              FluentIcons.brain_circuit_24_filled,
              color: colorScheme.primary,
            ),
            label: 'AI',
          ),
          NavigationDestination(
            icon: Icon(
              FluentIcons.heart_pulse_24_regular,
              color: colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              FluentIcons.heart_pulse_24_filled,
              color: colorScheme.primary,
            ),
            label: 'Health',
          ),
          NavigationDestination(
            icon: Icon(
              FluentIcons.person_24_regular,
              color: colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              FluentIcons.person_24_filled,
              color: colorScheme.primary,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _PatientDrawer extends StatelessWidget {
  const _PatientDrawer();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            ListTile(
              leading: Icon(
                FluentIcons.alert_24_regular,
                color: colorScheme.primary,
              ),
              title: Text(
                'Notifications & Reminders',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            ListTile(
              leading: Icon(
                FluentIcons.premium_24_regular,
                color: colorScheme.primary,
              ),
              title: Text(
                'Subscription Plans',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            ListTile(
              leading: Icon(
                FluentIcons.payment_24_regular,
                color: colorScheme.primary,
              ),
              title: Text(
                'Payment History',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            Divider(color: colorScheme.outlineVariant),
            ListTile(
              leading: Icon(
                FluentIcons.shield_lock_24_regular,
                color: colorScheme.primary,
              ),
              title: Text(
                'Privacy Policy',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            ListTile(
              leading: Icon(
                FluentIcons.document_text_24_regular,
                color: colorScheme.primary,
              ),
              title: Text(
                'Terms',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            ListTile(
              leading: Icon(
                FluentIcons.question_circle_24_regular,
                color: colorScheme.primary,
              ),
              title: Text(
                'Help & Support',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
