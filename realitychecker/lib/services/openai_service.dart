import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flashcard_model.dart';
import '../models/quiz_question_model.dart';
import 'package:uuid/uuid.dart';

class OpenAiService {
  static const String _apiKey = 'OPENROUTER_API_KEY';
  // OpenRouter base URL
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  // Free model available on OpenRouter
  static const String _model = 'openai/gpt-4o-mini';
  static const _uuid = Uuid();

  static Future<GeneratedStudyContent> generateStudyContent(String text) async {
    final prompt =
        '''
You are a study assistant. Given the text below, generate study materials.
Return ONLY a valid JSON object — no markdown, no extra text, no explanation.

Format exactly:
{
  "flashcards": [
    {"front": "Question or concept", "back": "Answer or explanation"}
  ],
  "quiz_questions": [
    {
      "question": "Question text",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "answer": "Option A",
      "explanation": "Why this is correct"
    }
  ]
}

Generate 10 flashcards and 5 quiz questions from this text:
${text.length > 12000 ? text.substring(0, 12000) : text}
''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'HTTP-Referer': 'com.example.realitychecker',
        'X-Title': 'Study AI',
      },
      body: jsonEncode({
        'model': _model,
        'temperature': 0.3,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a study assistant that returns only valid JSON with no extra text.',
          },
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      final msg = body['error']?['message'] ?? response.body;
      throw Exception('API error ${response.statusCode}: $msg');
    }

    final responseData = jsonDecode(response.body);
    String content = responseData['choices'][0]['message']['content'] as String;

    // Strip any markdown code fences
    content = content
        .replaceAll(RegExp(r'```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'```\s*', multiLine: true), '')
        .trim();

    final parsed = jsonDecode(content) as Map<String, dynamic>;

    final flashcards = (parsed['flashcards'] as List).map((f) {
      return FlashCard(
        id: _uuid.v4(),
        front: f['front'] as String,
        back: f['back'] as String,
      );
    }).toList();

    final quizQuestions = (parsed['quiz_questions'] as List).map((q) {
      return QuizQuestion(
        id: _uuid.v4(),
        question: q['question'] as String,
        options: List<String>.from(q['options'] as List),
        answer: q['answer'] as String,
        explanation: (q['explanation'] as String?) ?? '',
      );
    }).toList();

    return GeneratedStudyContent(
      flashcards: flashcards,
      quizQuestions: quizQuestions,
    );
  }
}

class GeneratedStudyContent {
  final List<FlashCard> flashcards;
  final List<QuizQuestion> quizQuestions;

  GeneratedStudyContent({
    required this.flashcards,
    required this.quizQuestions,
  });
}
