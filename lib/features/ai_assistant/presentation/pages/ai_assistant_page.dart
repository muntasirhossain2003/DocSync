// lib/features/ai_assistant/presentation/pages/ai_assistant_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../home/presentation/pages/doctors_by_specialty_page.dart';
import '../../../home/presentation/widgets/home_widgets.dart';

class AIAssistantPage extends ConsumerStatefulWidget {
  const AIAssistantPage({super.key});

  @override
  ConsumerState<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends ConsumerState<AIAssistantPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _recommendedSpecialization;
  GenerativeModel? _model;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
    _addWelcomeMessage();
  }

  void _initializeGemini() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      _addMessage(
        'Error: GEMINI_API_KEY not found in .env file. Please add it and restart the app.',
        isUser: false,
        isError: true,
      );
      return;
    }

    _model = GenerativeModel(model:'gemini-2.5-flash', apiKey: apiKey);
  }

  void _addWelcomeMessage() {
    _addMessage(
      'Hello! I\'m your AI Health Assistant. 👋\n\nDescribe your symptoms, and I\'ll help analyze them and recommend the appropriate medical specialist.',
      isUser: false,
    );
  }

  void _addMessage(String text, {required bool isUser, bool isError = false}) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: isUser,
          timestamp: DateTime.now(),
          isError: isError,
        ),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _model == null) return;

    final userMessage = _messageController.text.trim();
    _addMessage(userMessage, isUser: true);
    _messageController.clear();

    setState(() => _isLoading = true);

    try {
      final prompt =
          '''
You are a medical AI assistant. Analyze these symptoms and provide:

Symptoms: "$userMessage"

Provide a response in this format:
1. **Possible Conditions**: List 2-3 likely conditions
2. **Recommended Specialist**: Choose ONE from (Cardiologist, Dermatologist, Pediatrician, Neurologist, Orthopedic, Gynecologist, Psychiatrist, Dentist, ENT Specialist, General Physician)
3. **Advice**: Brief guidance and when to seek immediate care

Keep response concise, professional.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      final text = response.text ?? 'Unable to analyze symptoms';

      // Extract recommended specialization
      _extractSpecialization(text);

      _addMessage(text, isUser: false);
    } catch (e) {
      _addMessage(
        'Sorry, I encountered an error: ${e.toString()}',
        isUser: false,
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _extractSpecialization(String text) {
    final specializations = [
      'Cardiologist',
      'Dermatologist',
      'Pediatrician',
      'Neurologist',
      'Orthopedic',
      'Gynecologist',
      'Psychiatrist',
      'Dentist',
      'ENT Specialist',
      'General Physician',
    ];

    for (final spec in specializations) {
      if (text.toLowerCase().contains(spec.toLowerCase())) {
        setState(() => _recommendedSpecialization = spec);
        break;
      }
    }
  }

  void _navigateToSpecialist() {
    if (_recommendedSpecialization == null) return;

    // Find matching category
    final categories = ref.read(categoriesProvider);
    final matchingCategory = categories.firstWhere(
      (cat) => cat.specialization.toLowerCase().contains(
        _recommendedSpecialization!.toLowerCase(),
      ),
      orElse: () => categories.first,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DoctorsBySpecialtyPage(category: matchingCategory),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('AI Symptom Analysis'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Recommended Specialist Chip
          if (_recommendedSpecialization != null)
            Container(
              margin: const EdgeInsets.all(16),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                color: Colors.indigo,
                child: InkWell(
                  onTap: _navigateToSpecialist,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.local_hospital, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Recommended Specialist',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _recommendedSpecialization!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    child: const Icon(
                      Icons.medical_services,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Analyzing your symptoms...'),
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
            ),

          // Disclaimer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.amber.shade50,
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.amber.shade900,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI analysis is for informational purposes. Consult a doctor for medical advice.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Describe your symptoms...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!message.isUser)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: message.isError
                        ? Colors.red.shade100
                        : Colors.indigo.shade100,
                    child: Icon(
                      message.isError ? Icons.error : Icons.medical_services,
                      size: 16,
                      color: message.isError ? Colors.red : Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Assistant',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.indigo
                    : message.isError
                    ? Colors.red.shade50
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (!message.isUser)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser
                      ? Colors.white
                      : message.isError
                      ? Colors.red.shade900
                      : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// Chat Message Model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}
