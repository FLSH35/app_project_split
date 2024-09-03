import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:personality_score/screens/home_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Mock AuthService
class MockAuthService extends Mock implements AuthService {}

@GenerateMocks([AuthService])
void main() {
  Widget createHomeScreen() => ChangeNotifierProvider<AuthService>(
    create: (_) => MockAuthService(),
    child: MaterialApp(
      home: HomeScreen(),
      routes: {
        '/signin': (_) => Scaffold(body: Text('Sign In Screen')),
        '/profile': (_) => Scaffold(body: Text('Profile Screen')),
        '/questionnaire': (_) => Scaffold(body: Text('Questionnaire Screen')),
      },
    ),
  );

  group('HomeScreen Widget Tests', () {
    testWidgets('should display title, description and buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      // Verify the presence of the title
      expect(find.text('Personality Test'), findsOneWidget);

      // Verify the presence of the introductory text
      expect(find.text("It's so incredible to finally be understood."), findsOneWidget);

      // Verify the presence of the description text
      expect(find.text("Only 10 minutes to get a 'freakishly accurate' description of who you are and why you do things the way you do."), findsOneWidget);

      // Verify the presence of the 'Take the Test' button
      expect(find.text('Take the Test'), findsOneWidget);

      // Verify the presence of statistics
      expect(find.text('1M+'), findsOneWidget);
      expect(find.text('19M+'), findsOneWidget);
      expect(find.text('1204M+'), findsOneWidget);
      expect(find.text('91.2%'), findsOneWidget);
    });

    testWidgets('should navigate to profile screen on pressing profile button', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      // Tap the profile button
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Verify the profile screen is displayed
      expect(find.text('Profile Screen'), findsOneWidget);
    });

    testWidgets('should navigate to questionnaire screen on pressing Take the Test button', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      // Tap the 'Take the Test' button
      await tester.tap(find.text('Take the Test'));
      await tester.pumpAndSettle();

      // Verify the questionnaire screen is displayed
      expect(find.text('Questionnaire Screen'), findsOneWidget);
    });


  });
}
