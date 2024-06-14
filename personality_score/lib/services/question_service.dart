import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionService {
  Future<List<Question>> loadQuestions(String set) async {
    final String response = await rootBundle.loadString('assets/questions.json');
    final List<dynamic> data = json.decode(response);

    List<Question> questions = data
        .where((item) => item['set'] == set)
        .map((item) => Question.fromJson(item))
        .toList();

    return questions;
  }
}
