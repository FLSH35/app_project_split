import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personality_score/models/question.dart';


class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Question>> loadQuestions(String set) async {
    final snapshot = await _firestore.collection('questions').where('set', isEqualTo: set).get();
    return snapshot.docs.map((doc) => Question.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> saveUserData(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).set(data);
  }

  Future<Map<String, dynamic>?> loadUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }
}
