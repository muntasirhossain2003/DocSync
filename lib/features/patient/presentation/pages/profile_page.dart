import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                child: Icon(Icons.person, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.email ?? 'Patient',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Text('Care Plan: Basic'),
                  ],
                ),
              ),
              OutlinedButton(onPressed: () {}, child: const Text('Manage')),
            ],
          ),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.group),
            title: Text('Family Members'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.workspace_premium),
            title: Text('Subscriptions & Care Plans'),
          ),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
          ),
          const ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy Policy'),
          ),
          const ListTile(
            leading: Icon(Icons.description),
            title: Text('Terms of Service'),
          ),
          const ListTile(
            leading: Icon(Icons.help),
            title: Text('Help & Support'),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
