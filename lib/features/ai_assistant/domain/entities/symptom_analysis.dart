// lib/features/ai_assistant/domain/entities/symptom_analysis.dart

/// Represents the analysis result from AI for user symptoms
class SymptomAnalysis {
  final String rawResponse;
  final String? recommendedSpecialization;
  final List<String> possibleConditions;
  final String advice;

  const SymptomAnalysis({
    required this.rawResponse,
    this.recommendedSpecialization,
    required this.possibleConditions,
    required this.advice,
  });

  factory SymptomAnalysis.fromResponse(String response) {
    // Extract recommended specialization
    String? specialization;
    final List<String> conditions = [];
    String advice = '';

    // Parse the response
    final lines = response.split('\n');
    for (final line in lines) {
      if (line.toLowerCase().contains('recommended specialist:')) {
        // Extract specialization from the line
        specialization = line
            .replaceAll(RegExp(r'\*\*'), '')
            .replaceAll('Recommended Specialist:', '')
            .replaceAll('2.', '')
            .trim();
      }
    }

    return SymptomAnalysis(
      rawResponse: response,
      recommendedSpecialization: specialization,
      possibleConditions: conditions,
      advice: advice,
    );
  }
}
