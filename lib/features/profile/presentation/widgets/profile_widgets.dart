// lib/features/profile/presentation/widgets/profile_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/locale_provider.dart';
import '../../../../features/home/presentation/providers/user_provider.dart';
import '../../../../l10n/app_localizations.dart';
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
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.profilePictureUpdated,
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
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

class ProfileList extends ConsumerWidget {
  const ProfileList({super.key});

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(l10n.english),
                value: 'en',
                groupValue: currentLocale.languageCode,
                onChanged: (String? value) {
                  if (value != null) {
                    ref.read(localeProvider.notifier).setLocale(Locale(value));
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.languageChangedToEnglish),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              RadioListTile<String>(
                title: Text(l10n.bangla),
                value: 'bn',
                groupValue: currentLocale.languageCode,
                onChanged: (String? value) {
                  if (value != null) {
                    ref.read(localeProvider.notifier).setLocale(Locale(value));
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.languageChangedToEnglish),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageName = ref.watch(localeProvider.notifier).getLanguageName();

    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.workspace_premium),
          title: Text(l10n.subscriptionsAndCarePlans),
          onTap: () {
            context.push('/profile/subscription');
          },
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.language),
          subtitle: Text(languageName),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLanguageDialog(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text(l10n.settings),
          onTap: () {
            context.push('/profile/settings');
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: Text(l10n.privacyPolicy),
          onTap: () {
            context.push('/profile/privacy-policy');
          },
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: Text(l10n.termsOfService),
          onTap: () {
            context.push('/profile/terms-of-service');
          },
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: Text(l10n.helpAndSupport),
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
      label: Text(AppLocalizations.of(context)!.signOut),
    );
  }
}
