import 'dart:convert';               // Für utf8-Decode
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:math'; // Für Zufallsgenerator, falls erforderlich.

import '../models/question.dart';     // Falls du User-Model hast, optional


class QuestionService {
  // Instanzen für Firestore und Storage
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;


  final String baseUrl = 'https://us-central1-personality-score.cloudfunctions.net/get_filtered_questions';

  /// Fetches filtered questions based on the provided set.
  Future<List<Question>> fetchFilteredQuestions(String set) async {
    final uri = Uri.parse('$baseUrl?set=$set');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      // Parse the response body as a Map
      final Map<String, dynamic> data = json.decode(response.body);

      // Check if 'questions' key exists and is a List
      if (data.containsKey('questions') && data['questions'] is List) {
        final List<dynamic> questionsJson = data['questions'];

        // Map each JSON object to a Question instance
        final questions = questionsJson
            .map((json) => Question.fromJson(json as Map<String, dynamic>))
            .toList();

        // Randomize the order of questions
        questions.shuffle(Random());

        return questions;
      } else {
        throw Exception('Invalid response format: "questions" key not found or is not a List.');
      }
    } else {
      // Optionally, include more detailed error information
      throw Exception('Failed to load questions: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  // ----------------------------------------------------------------
  // Firestore-Funktionen für User-Daten (bleiben unverändert)
  // ----------------------------------------------------------------

  Future<void> saveUserData(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).set(data);
  }

  Future<Map<String, dynamic>?> loadUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }
}