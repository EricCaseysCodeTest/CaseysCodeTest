import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:json_placeholder_app/screens/posts_screen.dart';
import 'package:json_placeholder_app/providers/post_provider.dart';
import 'package:json_placeholder_app/models/post.dart';
import 'package:json_placeholder_app/models/comment.dart';
import '../helpers/test_helpers.dart';

@GenerateNiceMocks([MockSpec<PostProvider>()])
import 'posts_screen_test.mocks.dart';

void main() {
  late MockPostProvider mockPostProvider;

  setUp(() {
    mockPostProvider = MockPostProvider();
  });

  Widget createTestWidget() {
    return createProviderTestWidget(
      postProvider: mockPostProvider,
      child: const PostsScreen(),
    );
  }

  group('PostsScreen', () {
    final testPosts = [
      Post(id: 1, userId: 1, title: 'Test Post 1', body: 'Body 1'),
      Post(id: 2, userId: 1, title: 'Test Post 2', body: 'Body 2'),
    ];

    setUp(() {
      // Default mock behavior
      when(mockPostProvider.isLoading).thenReturn(false);
      when(mockPostProvider.posts).thenReturn([]);
      when(mockPostProvider.comments).thenReturn({});
    });

    testWidgets('shows loading indicator when loading',
        (WidgetTester tester) async {
      when(mockPostProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays posts when loaded', (WidgetTester tester) async {
      when(mockPostProvider.posts).thenReturn(testPosts);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Post 1'), findsOneWidget);
      expect(find.text('Test Post 2'), findsOneWidget);
      expect(find.byType(PostCard), findsNWidgets(2));
    });

    testWidgets('navigates to create screen on FAB tap',
        (WidgetTester tester) async {
      when(mockPostProvider.isLoading).thenReturn(false);
      when(mockPostProvider.posts).thenReturn([]);

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Create Post'), findsOneWidget);
    });

    testWidgets('shows error state when posts fail to load', (tester) async {
      when(mockPostProvider.isLoading).thenReturn(false);
      when(mockPostProvider.posts).thenReturn([]);
      when(mockPostProvider.fetchPosts())
          .thenAnswer((_) => Future.error(Exception('Network error')));

      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Wait for build
      await tester.pump(); // Wait for error UI update

      expect(find.text('Failed to load posts'), findsOneWidget);
    });

    testWidgets('handles post expansion and collapse', (tester) async {
      final post = Post(id: 1, userId: 1, title: 'Test Post', body: 'Body');
      when(mockPostProvider.posts).thenReturn([post]);
      when(mockPostProvider.comments).thenReturn({});
      when(mockPostProvider.fetchCommentsForPost(1))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Test Post'));
      await tester.pump(); // Wait for tap
      await tester.pump(); // Wait for expansion

      expect(find.byType(CommentsSection), findsOneWidget);

      await tester.tap(find.text('Test Post'));
      await tester.pump(); // Wait for tap
      await tester.pump(); // Wait for collapse

      expect(find.byType(CommentsSection), findsNothing);
    });
  });

  group('PostCard', () {
    final testPost = Post(id: 1, userId: 1, title: 'Test Post', body: 'Body');
    final testComments = [
      Comment(
        id: 1,
        postId: 1,
        name: 'Comment 1',
        email: 'test@test.com',
        body: 'Comment Body',
      ),
    ];

    testWidgets('expands to show comments on tap', (WidgetTester tester) async {
      when(mockPostProvider.comments).thenReturn({1: testComments});

      await tester.pumpWidget(
        createProviderTestWidget(
          postProvider: mockPostProvider,
          child: PostCard(post: testPost),
        ),
      );

      // Initially comments should not be visible
      expect(find.text('Comment 1'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('Test Post'));
      await tester.pump();

      // Comments should be visible
      expect(find.text('Comment 1'), findsOneWidget);
    });

    testWidgets('shows loading indicator when fetching comments',
        (WidgetTester tester) async {
      when(mockPostProvider.comments).thenReturn({});
      when(mockPostProvider.fetchCommentsForPost(1)).thenAnswer((_) async {});

      await tester.pumpWidget(
        createProviderTestWidget(
          postProvider: mockPostProvider,
          child: PostCard(post: testPost),
        ),
      );

      // Tap to expand
      await tester.tap(find.text('Test Post'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      verify(mockPostProvider.fetchCommentsForPost(1)).called(1);
    });
  });

  group('CommentsSection', () {
    testWidgets('shows error state when comments fail to load', (tester) async {
      final post = Post(id: 1, userId: 1, title: 'Test Post', body: 'Body');
      when(mockPostProvider.comments).thenReturn({});
      when(mockPostProvider.fetchCommentsForPost(1))
          .thenAnswer((_) => Future.error(Exception('Network error')));

      await tester.pumpWidget(createProviderTestWidget(
        postProvider: mockPostProvider,
        child: CommentsSection(postId: post.id!),
      ));

      await tester.pump(); // Wait for build
      await tester.pump(); // Wait for error UI update

      expect(find.text('Failed to load comments'), findsOneWidget);
    });
  });
}
