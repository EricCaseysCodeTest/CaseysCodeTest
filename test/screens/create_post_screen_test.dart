import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:json_placeholder_app/screens/create_post_screen.dart';
import 'package:json_placeholder_app/providers/post_provider.dart';
import 'package:json_placeholder_app/models/post.dart';
import '../helpers/test_helpers.dart';

@GenerateNiceMocks([MockSpec<PostProvider>()])
import 'create_post_screen_test.mocks.dart';

void main() {
  late MockPostProvider mockPostProvider;

  setUp(() {
    mockPostProvider = MockPostProvider();
  });

  Widget createTestWidget({Post? post}) {
    return createProviderTestWidget(
      postProvider: mockPostProvider,
      child: CreatePostScreen(post: post),
    );
  }

  group('CreatePostScreen', () {
    testWidgets('renders form fields correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Create Post'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty submit',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter a title'), findsOneWidget);
      expect(find.text('Please enter a body'), findsOneWidget);
    });

    testWidgets('calls createPost when form is valid',
        (WidgetTester tester) async {
      final expectedPost = Post(
        userId: 1,
        title: 'Test Title',
        body: 'Test Body',
      );

      when(mockPostProvider.createPost(any)).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Title'), 'Test Title');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Body'), 'Test Body');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verify(mockPostProvider.createPost(argThat(
        predicate<Post>((p) =>
            p.title == expectedPost.title && p.body == expectedPost.body),
      ))).called(1);
    });

    testWidgets('shows error message on create failure', (tester) async {
      when(mockPostProvider.createPost(any))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Title'), 'Test Title');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Body'), 'Test Body');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Error: Exception: Network error'), findsOneWidget);
    });
  });
}
