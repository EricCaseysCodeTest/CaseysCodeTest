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

      // Verify initial posts screen
      expect(find.text('Posts'), findsOneWidget);

      // Tap FAB to create new post
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify create post screen
      expect(find.text('Create Post'), findsOneWidget);

      // Enter post details
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Integration Test Title',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Body'),
        'Integration Test Body',
      );

      // Submit post
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify we're back on posts screen
      expect(find.text('Posts'), findsOneWidget);
      
      // Verify new post is visible (note: might not work with JSONPlaceholder
      // since it doesn't actually create posts)
      expect(find.text('Integration Test Title'), findsOneWidget);
    });

    testWidgets('Edit post flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for posts to load
      await tester.pump(const Duration(seconds: 2));

      // Find and tap the first post's edit button
      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();

      // Verify edit screen
      expect(find.text('Edit Post'), findsOneWidget);

      // Update post details
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Updated Title',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Body'),
        'Updated Body',
      );

      // Submit updates
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      // Verify we're back on posts screen
      expect(find.text('Posts'), findsOneWidget);
    });

    testWidgets('View comments flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for posts to load
      await tester.pump(const Duration(seconds: 2));

      // Find and tap the first post to expand
      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();

      // Wait for comments to load
      await tester.pump(const Duration(seconds: 2));

      // Verify comments are visible
      expect(find.byIcon(Icons.comment), findsWidgets);
    });

    testWidgets('Form validation', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to create post
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify validation messages
      expect(find.text('Please enter a title'), findsOneWidget);
      expect(find.text('Please enter a body'), findsOneWidget);

      // Enter only title
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Test Title',
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify body validation remains
      expect(find.text('Please enter a body'), findsOneWidget);
      expect(find.text('Please enter a title'), findsNothing);
    });

    testWidgets('Error handling UI feedback', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to create post
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter post details that might trigger an error
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'A' * 1000, // Very long title
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Body'),
        'Test Body',
      );

      // Submit and check for error message
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify error handling (SnackBar should appear)
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Network error handling', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for initial load
      await tester.pump(const Duration(seconds: 2));

      // Verify error state is shown (you'll need to modify your UI to show network errors)
      expect(find.text('Error loading posts'), findsOneWidget);
      
      // Test retry functionality
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      
      expect(find.text('Error loading posts'), findsNothing);
    });

    testWidgets('Post list scroll and lazy loading', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Scroll to bottom
      await tester.dragFrom(
        tester.getCenter(find.byType(ListView)),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      // Verify more posts are loaded
      expect(find.byType(PostCard), findsNWidgets(20)); // Assuming 10 per page
    });

    testWidgets('Comment expansion memory management', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Expand first post
      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      // Verify comments loaded
      expect(find.byType(ListTile), findsWidgets);

      // Collapse first post
      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();

      // Expand second post
      await tester.tap(find.byType(ExpansionTile).at(1));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      // Verify new comments loaded
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('Form input validation edge cases', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Test very long input
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

      // Test special characters
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

      // Open create screen
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter some text
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Test Title',
      );
      // Simulate app backgrounding/foregrounding 
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Verify form state preserved
      expect(
        find.widgetWithText(TextFormField, 'Test Title'),
        findsOneWidget,
      );
    });
  });
} 