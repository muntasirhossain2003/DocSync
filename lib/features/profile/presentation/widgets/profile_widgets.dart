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
      ],
    );
  }
}

class ProfileList extends StatelessWidget {
  const ProfileList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.workspace_premium),
          title: const Text('Subscriptions & Care Plans'),
          onTap: () {
            context.push('/profile/subscription');
          },
        ),
        const ListTile(
          leading: Icon(Icons.language),
          title: Text('Language'),
          // Language functionality to be implemented later
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            context.push('/profile/settings');
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacy Policy'),
          onTap: () {
            context.push('/profile/privacy-policy');
          },
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Terms of Service'),
          onTap: () {
            context.push('/profile/terms-of-service');
          },
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Help & Support'),
          onTap: () {
            context.push('/profile/help-support');
          },
        ),
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
