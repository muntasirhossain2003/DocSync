// lib/features/ai_assistant/data/repositories/ai_chat_repository_impl.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/symptom_analysis.dart';
import '../../domain/repositories/ai_chat_repository.dart';

class AIChatRepositoryImpl implements AIChatRepository {
  late final GenerativeModel _model;
  late final String _apiKey;

  AIChatRepositoryImpl() {
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
  }

  @override
  Future<SymptomAnalysis> analyzeSymptoms(String symptoms) async {
    try {
      final prompt = _buildImprovedPrompt(symptoms);
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text ?? 'Unable to analyze symptoms';

      return SymptomAnalysis.fromResponse(text);
    } catch (e) {
      throw Exception('Failed to analyze symptoms: $e');
    }
  }

  String _buildImprovedPrompt(String symptoms) {
    return '''
You are an expert medical AI assistant. Analyze the following symptoms with precision:

**Patient Symptoms:** "$symptoms"

Provide your response in this EXACT format using markdown:

## 🔍 Possible Conditions
- List 2-4 likely medical conditions based on these symptoms
- Be specific and relevant to the symptoms described

## 👨‍⚕️ Recommended Specialist
**Specialist Type:** [Choose the MOST appropriate ONE from this list]
- Cardiologist (heart, blood pressure, chest pain)
- Dermatologist (skin conditions, rashes, acne)
- Pediatrician (children's health)
- Neurologist (headaches, seizures, nerve issues)
- Orthopedist (bones, joints, fractures)
- Gynecologist & Obstetrician (women's reproductive health)
- Psychiatrist (mental health, depression, anxiety)
- Dentist (teeth, gums, oral health)
- Otolaryngologists (ENT) (ear, nose, throat issues)
- General Physician (general health, fever, cold, flu)
- Gastroenterologist (digestive system, stomach issues)
- Ophthalmologist (eye problems, vision)
- Pulmonologist (respiratory issues, breathing problems)
- Endocrinologist (diabetes, thyroid, hormones)
- Urologist (urinary tract, kidney issues)
- Oncologist (cancer-related)
- Nephrologist (kidney diseases)
- Rheumatologist (arthritis, autoimmune)

**Reasoning:** Explain why this specialist is recommended

## 💡 Medical Advice
- Immediate care needed: Yes/No and why
- Self-care recommendations
- When to seek urgent medical attention
- Any warning signs to watch for

## ⚠️ Important Disclaimer
This is AI-generated advice and not a substitute for professional medical diagnosis. Please consult a healthcare professional for accurate diagnosis and treatment.

Remember: Be precise, professional, and empathetic in your response.
''';
  }

  @override
  Future<List<Map<String, dynamic>>> getConversationHistory() async {
    // For now, return empty list. Can be implemented with local storage or backend
    return [];
  }

  @override
  Future<void> saveConversationHistory(
    List<Map<String, dynamic>> messages,
  ) async {
    // For now, do nothing. Can be implemented with local storage or backend
  }
}
