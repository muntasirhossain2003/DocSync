import 'package:flutter/material.dart';

import '../widgets/ai_widgets.dart';

class AIAssistantPage extends StatelessWidget {
  const AIAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ChatBubble(text: 'Hello! Describe your symptoms.', isMe: false),
              ],
            ),
          ),
          const SuggestedCard(),
          const ChatInput(),
        ],
      ),
    );
  }
}
