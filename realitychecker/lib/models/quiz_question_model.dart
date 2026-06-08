import 'dart:convert';

class QuizQuestion {
  String id;
  String question;
  List<String> options;
  String answer;
  String explanation;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    this.explanation = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'answer': answer,
        'explanation': explanation,
      };

  factory QuizQuestion.fromJson(Map<String, dynamic> j) => QuizQuestion(
        id: j['id'] as String,
        question: j['question'] as String,
        options: List<String>.from(j['options'] as List),
        answer: j['answer'] as String,
        explanation: (j['explanation'] as String?) ?? '',
      );

  static QuizQuestion fromJsonString(String s) =>
      QuizQuestion.fromJson(jsonDecode(s) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());
}
