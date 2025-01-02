import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../models/question.dart';

import 'package:personality_score/models/result.dart';


/// Creates the next results collection in Firestore and logs the attempt in BigQuery.
///
/// Returns:
/// - The name of the newly created results collection.
///
/// Throws:
/// - An exception if the user is not logged in, if fetching the highest result fails,
///   if creating the Firestore collection fails, or if logging the attempt in BigQuery fails.
Future<String> createNextResultsCollection(String user_uuid) async {

  try {
    // Get the highest result collection
    String highestResultCollection = await getHighestResultCollection(user_uuid);

    // Determine the next collection number
    int nextResultNumber = 1; // Default to 1 if no results exist
    if (highestResultCollection.isNotEmpty) {
      final match = RegExp(r'results_(\d+)').firstMatch(highestResultCollection);
      if (match != null) {
        nextResultNumber = int.parse(match.group(1)!) + 1;
      }
    }

    // Create the new collection name
    String newCollectionName = 'results_$nextResultNumber';

    // Create the new Firestore collection and initial document
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user_uuid)
        .collection(newCollectionName)
        .doc('finalCharacter') // Initial document
        .set({
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'initialized',
    });

    // Log the new test attempt in BigQuery via Cloud Function
    String createTestMessage = await createTestVersuch(user_uuid, newCollectionName);
    print("BigQuery Log: $createTestMessage");

    return newCollectionName;
  } catch (error) {
    print("Error creating next results collection: $error");
    throw Exception("Failed to create next results collection: $error");
  }
}

/// Calls the `create_test_versuch` Cloud Function to log a new test attempt.
///
/// Parameters:
/// - [userUuid]: The UUID of the user.
/// - [resultX]: The ResultX string representing the new test attempt.
///
/// Returns:
/// - A success message string if the operation is successful.
///
/// Throws:
/// - An exception if the request fails or if the response is invalid.
Future<String> createTestVersuch(String userUuid, String resultX) async {
  // Extract the integer x from resultX (e.g., 'results_5' -> 5)
  final int testVersuchName = _extractNumberFromResultX(resultX);

  // Replace with your actual Cloud Function URL
  final String cloudFunctionUrl = 'https://us-central1-personality-score.cloudfunctions.net/create_test_versuch';

  try {
    // Send a POST request with JSON body
    final response = await http.post(
      Uri.parse(cloudFunctionUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'User_UUID': userUuid,
        'Test_Versuch_Name': testVersuchName, // Send as integer
      }),
    );

    // Handle CORS preflight or other non-standard responses if necessary
    if (response.statusCode == 204) {
      // No Content, typically for OPTIONS requests
      return 'No Content';
    }

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Extract the success message
      if (data.containsKey('message')) {
        return data['message'] as String;
      } else {
        throw Exception("The response does not contain a 'message'.");
      }
    } else if (response.statusCode == 400 || response.statusCode == 404) {
      // Handle client errors
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? errorData['message'] ?? 'Client error.');
    } else {
      // Handle other non-success status codes
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to create test attempt.');
    }
  } catch (e) {
    // Handle any exceptions that occur during the request
    throw Exception('Error creating test attempt: $e');
  }
}

/// Helper function to extract integer from 'results_x'
int _extractNumberFromResultX(String resultX) {
  final RegExp regExp = RegExp(r'results_(\d+)');
  final Match? match = regExp.firstMatch(resultX);
  if (match != null && match.groupCount >= 1) {
    return int.parse(match.group(1)!);
  } else {
    throw FormatException("Invalid format for resultX: $resultX");
  }
}

/// Funktion zum Exportieren von Benutzerergebnissen.
///
/// [userUuid] ist die UUID des Benutzers.
/// [resultsX] ist der Name der Ergebnisse.
/// [combinedTotalScore] ist der kombinierte Gesamtscore.
/// [completionDate] ist das Abschlussdatum im ISO-Format.
/// [finalCharacter] ist der finale Charakter.
/// [finalCharacterDescription] ist die Beschreibung des finalen Charakters.
///
/// Gibt eine Map zurück, die die Antwort der Cloud-Funktion enthält,
/// oder wirft eine Ausnahme bei Fehlern.
Future<Map<String, dynamic>> exportUserResults({
  required String userUuid,
  required String resultsX,
  required int combinedTotalScore,
  required String finalCharacter,
  required String finalCharacterDescription,
  // Generiere das Abschlussdatum als ISO 8601-String in UTC
  required String completionDate
}) async {
  // Die URL deiner Cloud-Funktion
  final String url =
      'https://us-central1-personality-score.cloudfunctions.net/export_user_results';



  // Die zu sendenden Daten
  final Map<String, dynamic> requestBody = {
    'user_uuid': userUuid,
    'results_x': resultsX,
    'combined_total_score': combinedTotalScore,
    'completion_date': completionDate,
    'final_character': finalCharacter,
    'final_character_description': finalCharacterDescription,
  };

  try {
    // Sende eine POST-Anfrage mit JSON-Körper
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    // Überprüfe den Statuscode der Antwort
    if (response.statusCode == 200) {
      // Parse die JSON-Antwort
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } else {
      // Versuche, die Fehlernachricht aus der Antwort zu extrahieren
      String errorMessage = 'Fehler: ${response.statusCode}';

      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        }
      } catch (_) {
        // Ignoriere das Parsen, wenn es fehlschlägt
      }

      throw Exception(errorMessage);
    }
  } catch (e) {
    // Fange alle anderen Fehler ab
    throw Exception('Fehler beim Exportieren der Benutzerergebnisse: $e');
  }
}

/// Fetches the highest test result (`ResultsX`) for a given `userUuid` from the Cloud Function.
///
/// Returns the `results_x` string on success (e.g., 'results_5').
/// Throws an exception if the request fails or if the response is invalid.
/// Fetches the highest test result (`ResultsX`) for a given `userUuid` from the Cloud Function.
///
/// Returns the `results_x` string on success (e.g., 'results_5').
/// Throws an exception if the request fails or if the response is invalid.
Future<String> getHighestResultCollection(String userUuid) async {
  // Replace with your actual Cloud Function URL
  final String cloudFunctionUrl = 'https://us-central1-personality-score.cloudfunctions.net/get_highest_test_versuch';

  try {
    // Send a POST request with JSON body
    final response = await http.post(
      Uri.parse(cloudFunctionUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'User_UUID': userUuid}),
    );

    // Handle CORS preflight or other non-standard responses if necessary
    if (response.statusCode == 204) {
      // No Content, typically for OPTIONS requests
      return 'No Content';
    }

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Extract the 'MaxResultX' field
      if (data.containsKey('MaxResultX')) {
        final int maxResultX = data['MaxResultX'] as int;

        // Construct the 'results_x' string
        final String resultsX = 'results_$maxResultX';
        return resultsX;
      } else {
        throw Exception("The response does not contain 'MaxResultX'.");
      }
    } else if (response.statusCode == 404) {
      // Handle case where no results are found
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'No results found.');
    } else {
      // Handle other non-success status codes
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to fetch data.');
    }
  } catch (e) {
    // Handle any exceptions that occur during the request
    throw Exception('Error fetching ResultsX: $e');
  }
}

Future<Map<String, dynamic>> aggregateLebensbereiche({
  required String userUuid,
  required String resultsX,
}) async {

  try {
    final uri = Uri.parse('https://us-central1-personality-score.cloudfunctions.net/aggregate_lebensbereiche')
        .replace(queryParameters: {
      'User-UUID': userUuid,
      'ResultsX': resultsX,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    throw Exception('Failed to aggregate Lebensbereiche: ${response.statusCode}');
  } catch (e) {
    throw Exception('Error calling aggregate_lebensbereiche: $e');
  }
}

/// Function to export user answers by calling the exportUserAnswers Cloud Function
Future<void> exportUserAnswers(
    String user_uuid,
    String resultX,
    List<Question> _questions,
    List<int?> _answers) async {

  // Prepare the payload
  Map<String, dynamic> payload = {
    'userUuid': user_uuid,
    'resultsX': resultX, // Assuming resultX represents resultsX
    'answers': _answers.asMap().entries.map((entry) {
      int index = entry.key;
      int? answer = entry.value;

      // Correctly convert frageID to String
      String frageID = _questions[index].id.toString(); // Changed from 'as String' to '.toString()'

      return {
        'FrageID': frageID,
        'Answer': answer?.toString() ?? '5', // Defaulting to '5' if answer is null
      };
    }).toList(),
  };

  // Debug: Print the payload to verify types
  print("Payload being sent to Cloud Function: ${jsonEncode(payload)}");

  try {
    // Send POST request to the Cloud Function
    final response = await http.post(
      Uri.parse(
          "https://us-central1-personality-score.cloudfunctions.net/exportAnswersToBigQuery"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      // Success
      final responseData = jsonDecode(response.body);
      print(
          "Successfully exported answers to table: ${responseData['tableName']} with ${responseData['insertedRows']} rows.");
      // Optionally, show a success message to the user
    } else if (response.statusCode == 400) {
      // Client error
      final errorData = jsonDecode(response.body);
      print("Client Error: ${errorData['error']}");
      // Optionally, show an error message to the user
    } else {
      // Server error or other unexpected status codes
      final errorData = jsonDecode(response.body);
      print("Server Error: ${errorData['error']}");
      // Optionally, show an error message to the user
    }
  } catch (e) {
    // Network or parsing error
    print("Error exporting answers: $e");
    // Optionally, show an error message to the user
  }
}


Future<Result> fetchResultSummary(String userUUID, String resultsX) async {
  // Construct the URI with query parameters
  final uri = Uri.https(
    'us-central1-personality-score.cloudfunctions.net',
    '/get_result_summary',
    {
      'User-UUID': userUUID,
      'ResultsX': resultsX,
    },
  );

  try {
    // Make the HTTP GET request
    final response = await http.get(uri);

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Decode the JSON response
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Create and return a Result object from JSON
      return Result.fromJson(jsonResponse);
    } else {
      // Handle non-200 responses
      throw Exception(
          'Failed to load result summary. Status Code: ${response.statusCode}');
    }
  } catch (e) {
    // Handle any errors that occur during the request
    throw Exception('Error fetching result summary: $e');
  }
}

Future<void> updateUserFirestore({
  required String userUuid,
  required String? currentFinalCharacter,
  required String? currentCompletionDate,
  required int currentCombinedTotalScore,
  required String? currentFinalCharacterDescription,
}) async {
  try {
    // Define the payload
    final Map<String, dynamic> payload = {
      'user-uuid': userUuid,
      if (currentFinalCharacter != null) 'currentFinalCharacter': currentFinalCharacter,
      if (currentCompletionDate != null) 'currentCompletionDate': currentCompletionDate,
      if (currentCombinedTotalScore != null) 'currentCombinedTotalScore': currentCombinedTotalScore,
      if (currentFinalCharacterDescription != null) 'currentFinalCharakterDescription': currentFinalCharacterDescription,
    };

    // Send POST request to the Cloud Function
    final response = await http.post(
      Uri.parse("https://us-central1-personality-score.cloudfunctions.net/update_user_firestore"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    // Check the response status
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Update successful: ${responseData['message']}');
    } else {
      final errorData = jsonDecode(response.body);
      print('Error updating user: ${errorData['error']}');
    }
  } catch (e) {
    print('An exception occurred: $e');
  }
}