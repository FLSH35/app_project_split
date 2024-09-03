import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

Future<void> uploadQuestions() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load questions.json from assets
  String data = await rootBundle.loadString('assets/questions.json');
  List<dynamic> questions = json.decode(data);

  // Upload questions to Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  for (var question in questions) {
    await _firestore.collection('questions').add(question);
  }

  print('Questions uploaded successfully.');
}