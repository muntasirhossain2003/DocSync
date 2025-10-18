// lib/features/ai_assistant/presentation/providers/ai_chat_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/ai_chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../../domain/usecases/analyze_symptoms_usecase.dart';

/// Chat state that holds messages and loading state
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String? recommendedSpecialization;
  final String? reasoning;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.recommendedSpecialization,
    this.reasoning,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? recommendedSpecialization,
    String? reasoning,
    bool clearError = false,
    bool clearSpecialization = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      recommendedSpecialization: clearSpecialization
          ? null
          : (recommendedSpecialization ?? this.recommendedSpecialization),
      reasoning: clearSpecialization ? null : (reasoning ?? this.reasoning),
    );
  }
}

/// State notifier for chat operations
class ChatNotifier extends StateNotifier<ChatState> {
  final AnalyzeSymptomsUseCase _analyzeSymptomsUseCase;
  final _uuid = const Uuid();

  ChatNotifier(this._analyzeSymptomsUseCase) : super(const ChatState()) {
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: _uuid.v4(),
      text: '''
Hello! I'm your AI Health Assistant. 👋

Describe your symptoms in detail, and I'll help analyze them and recommend the appropriate medical specialist.

**For best results:**
- Describe your symptoms clearly
- Mention duration and severity
- Include any relevant medical history
''',
      isUser: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(messages: [welcomeMessage]);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      clearError: true,
    );

    try {
      // Analyze symptoms using use case
      final analysis = await _analyzeSymptomsUseCase(text);

      // Add AI response
      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        text: analysis.rawResponse,
        isUser: false,
        timestamp: DateTime.now(),
        recommendedSpecialization: analysis.recommendedSpecialization,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
        recommendedSpecialization: analysis.recommendedSpecialization,
        reasoning: analysis.reasoning,
      );
    } catch (e) {
      // Add error message
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        text: 'Sorry, I encountered an error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearChat() {
    state = const ChatState();
    _addWelcomeMessage();
  }
}

/// Provider for the AI chat repository
final aiChatRepositoryProvider = Provider<AIChatRepository>((ref) {
  return AIChatRepositoryImpl();
});

/// Provider for the analyze symptoms use case
final analyzeSymptomsUseCaseProvider = Provider<AnalyzeSymptomsUseCase>((ref) {
  final repository = ref.watch(aiChatRepositoryProvider);
  return AnalyzeSymptomsUseCase(repository);
});

/// Provider for the chat state
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final useCase = ref.watch(analyzeSymptomsUseCaseProvider);
  return ChatNotifier(useCase);
});
