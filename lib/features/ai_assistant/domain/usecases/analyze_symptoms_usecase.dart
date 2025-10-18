// lib/features/ai_assistant/domain/usecases/analyze_symptoms_usecase.dart

import '../entities/symptom_analysis.dart';
import '../repositories/ai_chat_repository.dart';

class AnalyzeSymptomsUseCase {
  final AIChatRepository _repository;

  AnalyzeSymptomsUseCase(this._repository);

  Future<SymptomAnalysis> call(String symptoms) async {
    if (symptoms.trim().isEmpty) {
      throw Exception('Please describe your symptoms');
    }

    return await _repository.analyzeSymptoms(symptoms);
  }
}
