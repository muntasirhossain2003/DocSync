// lib/features/ai_assistant/domain/entities/symptom_analysis.dart

/// Represents the analysis result from AI for user symptoms
class SymptomAnalysis {
  final String rawResponse;
  final String? recommendedSpecialization;
  final String? reasoning;
  final List<String> possibleConditions;
  final String advice;

  const SymptomAnalysis({
    required this.rawResponse,
    this.recommendedSpecialization,
    this.reasoning,
    required this.possibleConditions,
    required this.advice,
  });

  factory SymptomAnalysis.fromResponse(String response) {
    // Extract recommended specialization and reasoning
    String? specialization;
    String? reasoning;
    final List<String> conditions = [];
    String advice = '';

    // Parse the response
    final lines = response.split('\n');
    bool inRecommendedSection = false;
    bool foundSpecialistType = false;
    bool foundReasoning = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Detect when we enter the Recommended Specialist section
      if (line.toLowerCase().contains('recommended specialist')) {
        inRecommendedSection = true;
        continue;
      }

      // Extract specialist type
      if (inRecommendedSection && !foundSpecialistType) {
        if (line.toLowerCase().contains('specialist type:')) {
          specialization = line
              .replaceAll(RegExp(r'\*\*'), '')
              .replaceAll('Specialist Type:', '')
              .replaceAll('2.', '')
              .trim();
          foundSpecialistType = true;
          continue;
        }
      }

      // Extract reasoning
      if (inRecommendedSection && foundSpecialistType && !foundReasoning) {
        if (line.toLowerCase().contains('reasoning:')) {
          // Get the reasoning text, which might span multiple lines
          String reasoningText = line
              .replaceAll(RegExp(r'\*\*'), '')
              .replaceAll('Reasoning:', '')
              .trim();

          // Check next few lines for continuation
          for (int j = i + 1; j < lines.length && j < i + 5; j++) {
            final nextLine = lines[j].trim();
            // Stop if we hit another section
            if (nextLine.startsWith('#') ||
                nextLine.toLowerCase().contains('medical advice') ||
                nextLine.isEmpty) {
              break;
            }
            reasoningText += ' ' + nextLine;
          }

          reasoning = reasoningText.trim();
          foundReasoning = true;
          inRecommendedSection = false;
          break;
        }
      }
    }

    return SymptomAnalysis(
      rawResponse: response,
      recommendedSpecialization: specialization,
      reasoning: reasoning,
      possibleConditions: conditions,
      advice: advice,
    );
  }
}
