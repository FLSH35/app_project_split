import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class NewsletterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String apiUrl = 'https://ifyouchange42862.api-us1.com/api/3';
  //final String apiKey = 'a8bb1fd8ba76b2b1a0c2c58b1745ba2fc458e5f69da898048ccd790b14a5206db1bd9ef7';

  final Map<String, String> headers = {
    'Api-Token': 'a8bb1fd8ba76b2b1a0c2c58b1745ba2fc458e5f69da898048ccd790b14a5206db1bd9ef7',
    'Content-Type': 'application/json',
  };

  // 1. Get contact by email
  Future<Map<String, dynamic>?> getContactByEmail(String email) async {
    final response = await http.get(
      Uri.parse('$apiUrl/contacts?email=$email'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['contacts'] != null && data['contacts'].isNotEmpty) {
        return data['contacts'][0];
      }
    }
    return null;
  }

  // 2. Create or get contact
  Future<Map<String, dynamic>?> createOrGetContact(String email) async {
    final contact = await getContactByEmail(email);
    if (contact != null) {
      print('Contact with email $email already exists.');
      return contact;
    }

    final data = {
      "contact": {
        "email": email,
      },
    };

    final response = await http.post(
      Uri.parse('$apiUrl/contacts'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body)['contact'];
    } else {
      print('Error creating contact: ${response.body}');
      return null;
    }
  }

  // 3. Get list by name
  Future<Map<String, dynamic>?> getListByName(String listName) async {
    final response = await http.get(
      Uri.parse('$apiUrl/lists'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['lists'] != null) {
        return data['lists']
            .firstWhere((list) => list['name'] == listName, orElse: () => null);
      }
    }
    return null;
  }

  // 4. Create or get list
  Future<Map<String, dynamic>?> createOrGetList(String listName) async {
    final list = await getListByName(listName);
    if (list != null) {
      print('List with name "$listName" already exists.');
      return list;
    }

    final data = {
      "list": {
        "name": listName,
        "stringid": listName.toLowerCase().replaceAll(' ', '_'),
        "sender_url": "https://ifyouchange42862.activehosted.com/",
        "sender_reminder":
        "You are receiving this email because you signed up on our website.",
      },
    };

    final response = await http.post(
      Uri.parse('$apiUrl/lists'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body)['list'];
    } else {
      print('Error creating list: ${response.body}');
      return null;
    }
  }

  // 5. Add contact to list
  Future<bool> addContactToList(int contactId, int listId) async {
    final data = {
      "contactList": {
        "list": listId,
        "contact": contactId,
        "status": 1, // 1 for active
      },
    };

    final response = await http.post(
      Uri.parse('$apiUrl/contactLists'),
      headers: headers,
      body: json.encode(data),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Function to handle full process
  Future<void> subscribeToNewsletter(String email, String listName) async {
    final contact = await createOrGetContact(email);
    if (contact == null) {
      print('Failed to create or retrieve contact.');
      return;
    }

    final list = await createOrGetList(listName);
    if (list == null) {
      print('Failed to create or retrieve list.');
      return;
    }

    final success = await addContactToList(contact['id'], list['id']);
    if (success) {
      print('Successfully added contact to the list.');
    } else {
      print('Failed to add contact to the list.');
    }
  }

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
