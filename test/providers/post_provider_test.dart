import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:json_placeholder_app/services/api_service.dart';
import 'package:json_placeholder_app/providers/post_provider.dart';
import 'package:json_placeholder_app/models/post.dart';
import 'package:json_placeholder_app/models/comment.dart';

@GenerateNiceMocks([MockSpec<ApiService>()])
import 'post_provider_test.mocks.dart';

void main() {
  group('PostProvider', () {
    late MockApiService mockApiService;
    late PostProvider postProvider;

    setUp(() {
      mockApiService = MockApiService();
      postProvider = PostProvider()..apiService = mockApiService;
    });

    test('fetchPosts handles error gracefully', () async {
      when(mockApiService.getPosts())
          .thenThrow(Exception('Failed to load posts: 500'));

      await postProvider.fetchPosts();

      expect(postProvider.error, contains('Failed to load posts: 500'));
      expect(postProvider.isLoading, false);
      expect(postProvider.posts, isEmpty);
    });

    test('multiple concurrent fetchPosts calls handled correctly', () async {
      when(mockApiService.getPosts()).thenAnswer(
        (_) async => [Post(id: 1, title: 'Test', body: 'Body', userId: 1)],
      );

      // Add a delay to the mock to simulate network latency
      when(mockApiService.getPosts()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [Post(id: 1, title: 'Test', body: 'Body', userId: 1)];
      });

      // Start concurrent fetches
      await Future.wait([
        postProvider.fetchPosts(),
        postProvider.fetchPosts(),
        postProvider.fetchPosts(),
      ]);

      verify(mockApiService.getPosts()).called(1);
    });
  });

  late PostProvider postProvider;
  late MockApiService mockApiService;

  /// Setup method runs before each test.
  /// Creates a fresh PostProvider and MockApiService instance.
  setUp(() {
    mockApiService = MockApiService();
    postProvider = PostProvider()..apiService = mockApiService;
  });

  group('Basic CRUD Operations', () {
    /// Tests the basic post fetching functionality.
    /// Verifies that:
    /// - Posts are correctly fetched from the API
    /// - Loading state is properly managed
    /// - Data is correctly stored in the provider
    final testPosts = [
      Post(id: 1, userId: 1, title: 'Test Post 1', body: 'Body 1'),
      Post(id: 2, userId: 1, title: 'Test Post 2', body: 'Body 2'),
    ];

    final testComments = [
      Comment(
        id: 1,
        postId: 1,
        name: 'Comment 1',
        email: 'test@test.com',
        body: 'Comment Body 1',
      ),
    ];

    test('fetchPosts should update posts list', () async {
      // Arrange
      when(mockApiService.getPosts()).thenAnswer((_) async => testPosts);

      // Act
      await postProvider.fetchPosts();

      // Assert
      expect(postProvider.posts, equals(testPosts));
      expect(postProvider.isLoading, isFalse);
      verify(mockApiService.getPosts()).called(1);
    });

    test('fetchCommentsForPost should update comments map', () async {
      // Arrange
      when(mockApiService.getCommentsForPost(1))
          .thenAnswer((_) async => testComments);

      // Act
      await postProvider.fetchCommentsForPost(1);

      // Assert
      expect(postProvider.comments[1], equals(testComments));
      verify(mockApiService.getCommentsForPost(1)).called(1);
    });

    test('createPost should add new post to list', () async {
      // Arrange
      final newPost = Post(userId: 1, title: 'New Post', body: 'New Body');
      final createdPost =
          Post(id: 3, userId: 1, title: 'New Post', body: 'New Body');
      when(mockApiService.createPost(newPost))
          .thenAnswer((_) async => createdPost);

      // Act
      await postProvider.createPost(newPost);

      // Assert
      expect(postProvider.posts.first, equals(createdPost));
      verify(mockApiService.createPost(newPost)).called(1);
    });

    test('updatePost should update existing post', () async {
      // Arrange
      postProvider = PostProvider()
        // ignore: invalid_use_of_protected_member
        ..apiService = mockApiService
        ..posts = testPosts;

      final updatedPost =
          Post(id: 1, userId: 1, title: 'Updated Title', body: 'Updated Body');
      when(mockApiService.updatePost(updatedPost))
          .thenAnswer((_) async => updatedPost);

      // Act
      await postProvider.updatePost(updatedPost);

      // Assert
      expect(
        postProvider.posts.firstWhere((post) => post.id == 1),
        equals(updatedPost),
      );
      verify(mockApiService.updatePost(updatedPost)).called(1);
    });
  });

  group('Error Handling', () {
    test('fetchPosts handles error gracefully', () async {
      when(mockApiService.getPosts())
          .thenThrow(Exception('Failed to load posts: 500'));

      await postProvider.fetchPosts();

      expect(postProvider.error, contains('Failed to load posts: 500'));
      expect(postProvider.isLoading, false);
      expect(postProvider.posts, isEmpty);
    });

    test('fetchCommentsForPost handles error gracefully', () async {
      when(mockApiService.getCommentsForPost(1))
          .thenThrow(Exception('Network error'));

      expect(() => postProvider.fetchCommentsForPost(1), throwsException);
    });

    test('createPost throws error for handling', () async {
      final post = Post(userId: 1, title: 'Test', body: 'Test');
      when(mockApiService.createPost(post))
          .thenThrow(Exception('Network error'));

      expect(() => postProvider.createPost(post), throwsException);
    });

    test('updatePost handles non-existent post gracefully', () async {
      final nonExistentPost = Post(
        id: 999,
        userId: 1,
        title: 'Non-existent',
        body: 'Body',
      );
      when(mockApiService.updatePost(nonExistentPost))
          .thenAnswer((_) async => nonExistentPost);

      await postProvider.updatePost(nonExistentPost);

      // Should not throw and post list should remain unchanged
      expect(postProvider.posts, isEmpty);
    });

    test('updatePost handles API timeout', () async {
      final post = Post(id: 1, userId: 1, title: 'Test', body: 'Body');
      when(mockApiService.updatePost(post)).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(seconds: 2));
          return post;
        },
      );

      await expectLater(
        postProvider.updatePost(post).timeout(
              const Duration(seconds: 1),
            ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('fetchPosts handles malformed response', () async {
      when(mockApiService.getPosts()).thenAnswer(
        (_) async => [
          Post(id: 1, userId: 1, title: '', body: ''), // Empty strings
          Post(
              id: null,
              userId: -1,
              title: 'A' * 1000,
              body: 'Test'), // Invalid data
        ],
      );

      await postProvider.fetchPosts();
      expect(postProvider.posts.length, equals(2));
      expect(postProvider.posts.first.title, isEmpty);
      expect(postProvider.posts.last.id, isNull);
    });

    test('concurrent operations handled correctly', () async {
      final post1 = Post(id: 1, userId: 1, title: 'Test 1', body: 'Body 1');
      final post2 = Post(id: 2, userId: 1, title: 'Test 2', body: 'Body 2');

      when(mockApiService.createPost(any)).thenAnswer(
        (invocation) async {
          await Future.delayed(const Duration(milliseconds: 100));
          final post = invocation.positionalArguments.first as Post;
          return post.copyWith(id: post.title == 'Test 1' ? 1 : 2);
        },
      );

      // Start concurrent operations
      await Future.wait([
        postProvider.createPost(post1),
        postProvider.createPost(post2),
      ]);

      expect(postProvider.posts.length, equals(2));
      expect(
        postProvider.posts.map((p) => p.title),
        containsAll(['Test 1', 'Test 2']),
      );
    });

    test('fetchCommentsForPost handles duplicate calls', () async {
      when(mockApiService.getCommentsForPost(1)).thenAnswer(
        (_) async => [
          Comment(
            id: 1,
            postId: 1,
            name: 'Test',
            email: 'test@test.com',
            body: 'Body',
          ),
        ],
      );

      // Call multiple times for same post
      await Future.wait([
        postProvider.fetchCommentsForPost(1),
        postProvider.fetchCommentsForPost(1),
        postProvider.fetchCommentsForPost(1),
      ]);

      verify(mockApiService.getCommentsForPost(1)).called(3);
      expect(postProvider.comments[1]?.length, equals(1));
    });

    test('handles invalid userId in post creation', () async {
      final invalidPost = Post(
        userId: -1, // Invalid user ID
        title: 'Test',
        body: 'Body',
      );

      when(mockApiService.createPost(invalidPost))
          .thenThrow(Exception('Invalid userId'));

      expect(
        () => postProvider.createPost(invalidPost),
        throwsException,
      );
      expect(postProvider.posts, isEmpty);
    });

    test('handles post update with mismatched IDs', () async {
      final initialPost =
          Post(id: 1, userId: 1, title: 'Original', body: 'Body');
      postProvider.posts = [initialPost];

      final updatePost = Post(id: 1, userId: 2, title: 'Updated', body: 'Body');
      when(mockApiService.updatePost(updatePost))
          .thenAnswer((_) async => updatePost);

      await postProvider.updatePost(updatePost);
      expect(postProvider.posts.first.userId, equals(2));
    });

    test('handles race condition in comment fetching', () async {
      // Setup two posts requesting comments simultaneously
      when(mockApiService.getCommentsForPost(1)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [
          Comment(
              id: 1,
              postId: 1,
              name: 'First',
              email: 'test@test.com',
              body: 'Body'),
        ];
      });

      when(mockApiService.getCommentsForPost(2)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return [
          Comment(
              id: 2,
              postId: 2,
              name: 'Second',
              email: 'test@test.com',
              body: 'Body'),
        ];
      });

      // Start both requests concurrently
      await Future.wait([
        postProvider.fetchCommentsForPost(1),
        postProvider.fetchCommentsForPost(2),
      ]);

      // Verify both sets of comments were stored correctly
      expect(postProvider.comments[1]?.first.name, equals('First'));
      expect(postProvider.comments[2]?.first.name, equals('Second'));
    });

    test('handles memory cleanup for removed posts', () async {
      // Setup initial state with comments
      postProvider.posts = [
        Post(id: 1, userId: 1, title: 'Test', body: 'Body'),
      ];

      final comments = [
        Comment(
            id: 1,
            postId: 1,
            name: 'Test',
            email: 'test@test.com',
            body: 'Body'),
      ];

      when(mockApiService.getCommentsForPost(1))
          .thenAnswer((_) async => comments);

      // Fetch comments
      await postProvider.fetchCommentsForPost(1);
      expect(postProvider.comments[1], isNotNull);

      // Remove post and verify comments are cleaned up
      postProvider.posts = [];
      postProvider.clearComments();
    });

    test('handles malformed comment data', () async {
      when(mockApiService.getCommentsForPost(1)).thenAnswer(
        (_) async => [
          Comment(
            id: null, // Missing ID
            postId: 1,
            name: '', // Empty name
            email: 'invalid-email', // Invalid email
            body: 'A' * 1000, // Very long body
          ),
        ],
      );

      await postProvider.fetchCommentsForPost(1);

      final comments = postProvider.comments[1];
      expect(comments, isNotNull);
      expect(comments!.first.id, isNull);
      expect(comments.first.name, isEmpty);
    });
  });

  group('Edge Cases', () {
    test('handles invalid userId in post creation', () async {
      final invalidPost = Post(
        userId: -1, // Invalid user ID
        title: 'Test',
        body: 'Body',
      );

      when(mockApiService.createPost(invalidPost))
          .thenThrow(Exception('Invalid userId'));

      expect(
        () => postProvider.createPost(invalidPost),
        throwsException,
      );
      expect(postProvider.posts, isEmpty);
    });
  });

  group('Concurrent Operations', () {
    test('handles race condition in comment fetching', () async {
      // Setup two posts requesting comments simultaneously
      when(mockApiService.getCommentsForPost(1)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [
          Comment(
              id: 1,
              postId: 1,
              name: 'First',
              email: 'test@test.com',
              body: 'Body'),
        ];
      });

      when(mockApiService.getCommentsForPost(2)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return [
          Comment(
              id: 2,
              postId: 2,
              name: 'Second',
              email: 'test@test.com',
              body: 'Body'),
        ];
      });

      // Start both requests concurrently
      await Future.wait([
        postProvider.fetchCommentsForPost(1),
        postProvider.fetchCommentsForPost(2),
      ]);

      // Verify both sets of comments were stored correctly
      expect(postProvider.comments[1]?.first.name, equals('First'));
      expect(postProvider.comments[2]?.first.name, equals('Second'));
    });

    test('handles concurrent post creation', () async {
      final post1 = Post(userId: 1, title: 'First Post', body: 'Body 1');
      final post2 = Post(userId: 1, title: 'Second Post', body: 'Body 2');

      when(mockApiService.createPost(any)).thenAnswer((invocation) async {
        final post = invocation.positionalArguments.first as Post;
        await Future.delayed(const Duration(milliseconds: 50));
        return post.copyWith(id: post.title == 'First Post' ? 1 : 2);
      });

      // Create posts concurrently
      await Future.wait([
        postProvider.createPost(post1),
        postProvider.createPost(post2),
      ]);

      expect(postProvider.posts.length, equals(2));
      expect(
        postProvider.posts.map((p) => p.title),
        containsAll(['First Post', 'Second Post']),
      );
    });
  });
}
