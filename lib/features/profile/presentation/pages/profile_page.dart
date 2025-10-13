import 'package:flutter/material.dart';

import '../widgets/profile_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ProfileHeader(),
          SizedBox(height: 16),
          ProfileList(),
          SizedBox(height: 24),
          SignOutButton(),
        ],
      ),
    );
  }
}
