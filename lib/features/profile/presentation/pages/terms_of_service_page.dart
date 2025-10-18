import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DocSync Terms of Service',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: October 18, 2025',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Acceptance of Terms',
              'By accessing and using DocSync, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            _buildSection(
              'Use of Services',
              'You agree to use our services only for lawful purposes and in accordance with these Terms. You are responsible for:\n\n'
                  '• Maintaining the confidentiality of your account\n'
                  '• All activities that occur under your account\n'
                  '• Ensuring the accuracy of your information',
            ),
            _buildSection(
              'Medical Disclaimer',
              'DocSync provides a platform to connect patients with healthcare providers. The platform does not provide medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions regarding a medical condition.',
            ),
            _buildSection(
              'Consultation Guidelines',
              'When using our consultation services:\n\n'
                  '• Provide accurate and complete medical information\n'
                  '• Consultations are not for emergency situations\n'
                  '• Follow-up with in-person care when recommended\n'
                  '• Maintain professionalism during consultations',
            ),
            _buildSection(
              'Payment Terms',
              'You agree to pay all fees associated with your use of our services. All payments are processed securely and are non-refundable unless otherwise specified.',
            ),
            _buildSection(
              'Limitation of Liability',
              'DocSync shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use or inability to use the service.',
            ),
            _buildSection(
              'Changes to Terms',
              'We reserve the right to modify these terms at any time. We will notify users of any material changes via email or through the application.',
            ),
            _buildSection(
              'Contact Information',
              'For questions about these Terms, please contact us at:\n\n'
                  'Email: legal@docsync.com\n'
                  'Phone: +1 (555) 123-4567',
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
