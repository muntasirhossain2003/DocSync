import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DocSync Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: October 18, 2025',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Introduction',
              'DocSync is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our telemedicine application.',
            ),
            _buildSection(
              'Information We Collect',
              'We collect information that you provide directly to us, including:\n\n'
                  '• Personal identification information (name, email, phone number)\n'
                  '• Health information and medical records\n'
                  '• Payment and billing information\n'
                  '• Consultation history and communications',
            ),
            _buildSection(
              'How We Use Your Information',
              'We use the information we collect to:\n\n'
                  '• Provide and maintain our services\n'
                  '• Process your consultations and appointments\n'
                  '• Send you important updates and notifications\n'
                  '• Improve our services and user experience',
            ),
            _buildSection(
              'Data Security',
              'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
            ),
            _buildSection(
              'Your Rights',
              'You have the right to:\n\n'
                  '• Access your personal information\n'
                  '• Request correction of your data\n'
                  '• Request deletion of your data\n'
                  '• Opt-out of marketing communications',
            ),
            _buildSection(
              'Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at support@docsync.com',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
