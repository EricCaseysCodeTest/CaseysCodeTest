import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:json_placeholder_app/main.dart' as app;
import 'package:json_placeholder_app/screens/posts_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Create and view post flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Posts'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Create Post'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Integration Test Title',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Body'),
        'Integration Test Body',
      );

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Posts'), findsOneWidget);

      expect(find.text('Integration Test Title'), findsOneWidget);
    });

    testWidgets('Edit post flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();

      expect(find.text('Edit Post'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Updated Title',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Body'),
        'Updated Body',
      );

      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      expect(find.text('Posts'), findsOneWidget);
    });

    testWidgets('View comments flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));

      expect(find.byIcon(Icons.comment), findsWidgets);
    });

    testWidgets('Form validation', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a title'), findsOneWidget);
      expect(find.text('Please enter a body'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Test Title',
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a body'), findsOneWidget);
      expect(find.text('Please enter a title'), findsNothing);
    });

    testWidgets('Error handling UI feedback', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'A' * 1000,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Body'),
        'Test Body',
      );

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Network error handling', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Error loading posts'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Error loading posts'), findsNothing);
    });

    testWidgets('Post list scroll and lazy loading', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.dragFrom(
        tester.getCenter(find.byType(ListView)),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PostCard), findsNWidgets(20));
    });

    testWidgets('Comment expansion memory management', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(ListTile), findsWidgets);

      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ExpansionTile).at(1));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('Form input validation edge cases', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'A' * 500,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Body'),
        'B' * 5000,
      );

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        '!@#\$%^&*()',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Body'),
        '🎉 Unicode 🚀 Test',
      );

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
    });

    testWidgets('Navigation state preservation', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Test Title',
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextFormField, 'Test Title'),
        findsOneWidget,
      );
    });
  });
}
