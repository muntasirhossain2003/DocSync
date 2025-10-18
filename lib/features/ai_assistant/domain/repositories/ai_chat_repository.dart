// lib/features/ai_assistant/domain/repositories/ai_chat_repository.dart

import '../entities/symptom_analysis.dart';

/// Repository interface for AI chat operations
abstract class AIChatRepository {
  /// Analyzes user symptoms and returns AI response
  Future<SymptomAnalysis> analyzeSymptoms(String symptoms);

  /// Gets conversation history (for future implementation with backend)
  Future<List<Map<String, dynamic>>> getConversationHistory();

  /// Saves conversation history (for future implementation with backend)
  Future<void> saveConversationHistory(List<Map<String, dynamic>> messages);
}
