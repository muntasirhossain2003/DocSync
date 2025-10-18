// lib/features/profile/presentation/widgets/profile_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../features/home/presentation/providers/user_provider.dart';
import '../../../../shared/widgets/profile_image_picker.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final userAsync = ref.watch(currentUserProvider);

    return Column(
      children: [
        // Profile Image Picker
        userAsync.when(
          data: (userData) => ProfileImagePicker(
            currentImageUrl: userData?.profilePictureUrl,
            size: 100,
            onImageUploaded: (newImageUrl) {
              // Refresh user data after upload
              ref.invalidate(currentUserProvider);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile picture updated!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          loading: () => const CircleAvatar(
            radius: 50,
            child: CircularProgressIndicator(),
          ),
          error: (_, __) => const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
        ),
        const SizedBox(height: 16),

        // User Info
        Text(
          user?.email ?? 'Patient',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: () {
          context.push('/profile/subscription');
        }, child: const Text('Manage Plan')),
      ],
    );
  }
}

class ProfileList extends StatelessWidget {
  const ProfileList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ListTile(leading: Icon(Icons.group), title: Text('Family Members')),
        Divider(),
        ListTile(
          leading: Icon(Icons.workspace_premium),
          title: Text('Subscriptions & Care Plans'),
        ),
        ListTile(leading: Icon(Icons.language), title: Text('Language')),
        ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
        Divider(),
        ListTile(
          leading: Icon(Icons.privacy_tip),
          title: Text('Privacy Policy'),
        ),
        ListTile(
          leading: Icon(Icons.description),
          title: Text('Terms of Service'),
        ),
        ListTile(leading: Icon(Icons.help), title: Text('Help & Support')),
      ],
    );
  }
}

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () async {
        await Supabase.instance.client.auth.signOut();
        if (context.mounted) {
          Navigator.pop(context);
          context.go('/login');
        }
      },
      icon: const Icon(Icons.logout),
      label: const Text('Sign out'),
    );
  }
}
