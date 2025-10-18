import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'How can we help you?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildContactCard(
            context,
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@docsync.com',
            onTap: () => _launchEmail(),
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            context,
            icon: Icons.phone_outlined,
            title: 'Phone Support',
            subtitle: '+1 (555) 123-4567',
            onTap: () => _launchPhone(),
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            context,
            icon: Icons.chat_outlined,
            title: 'Live Chat',
            subtitle: 'Available 24/7',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Live chat coming soon!')),
              );
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFAQItem(
            'How do I book a consultation?',
            'Navigate to the Consult tab, select your preferred doctor, and click the "Book" button to schedule an appointment.',
          ),
          _buildFAQItem(
            'How do I start a video call?',
            'When it\'s time for your appointment, go to your upcoming consultations and click "Join Call" or use the "Call Now" button if the doctor is available.',
          ),
          _buildFAQItem(
            'Can I cancel or reschedule?',
            'Yes, you can cancel or reschedule up to 2 hours before your appointment time through the consultation details page.',
          ),
          _buildFAQItem(
            'How do I update my profile?',
            'Go to the Profile tab and tap on your profile picture or name to edit your information.',
          ),
          _buildFAQItem(
            'What payment methods do you accept?',
            'We accept credit cards, debit cards, and various digital payment methods. All transactions are secure and encrypted.',
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'Need More Help?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Visit our comprehensive help center for detailed guides and tutorials.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Help center coming soon!'),
                        ),
                      );
                    },
                    child: const Text('Visit Help Center'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer, style: const TextStyle(height: 1.5)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@docsync.com',
      query: 'subject=Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+15551234567');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
