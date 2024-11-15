import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewsletterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches the newsletter subscription status for the current user.
  Future<bool> fetchNewsletterStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc['isSubscribedToNewsletter'] ?? false;
    }
    throw Exception('User is not logged in');
  }

  /// Updates the newsletter subscription status for the current user.
  Future<void> updateNewsletterStatus(bool isSubscribed) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'isSubscribedToNewsletter': isSubscribed});
    } else {
      throw Exception('User is not logged in');
    }
  }
}
