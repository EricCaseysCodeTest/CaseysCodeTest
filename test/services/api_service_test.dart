import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:json_placeholder_app/services/api_service.dart';
import 'package:json_placeholder_app/models/post.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
import 'api_service_test.mocks.dart';

void main() {
  late ApiService apiService;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    apiService = ApiService(mockClient);
  });

  group('ApiService', () {
    test('getPosts returns list of posts', () async {
      final response = [
        {'id': 1, 'userId': 1, 'title': 'Test', 'body': 'Body'}
      ];

      when(mockClient.get(Uri.parse('${ApiService.baseUrl}/posts')))
          .thenAnswer((_) async => http.Response(json.encode(response), 200));

      final posts = await apiService.getPosts();

      expect(posts.length, equals(1));
      expect(posts.first.title, equals('Test'));
    });

    test('getCommentsForPost returns list of comments', () async {
      final response = [
        {
          'id': 1,
          'postId': 1,
          'name': 'Test',
          'email': 'test@test.com',
          'body': 'Comment'
        }
      ];

      when(mockClient.get(Uri.parse('${ApiService.baseUrl}/posts/1/comments')))
          .thenAnswer((_) async => http.Response(json.encode(response), 200));

      final comments = await apiService.getCommentsForPost(1);

      expect(comments.length, equals(1));
      expect(comments.first.name, equals('Test'));
    });

    test('createPost returns created post', () async {
      final post = Post(userId: 1, title: 'Test', body: 'Body');
      final response = {'id': 1, 'userId': 1, 'title': 'Test', 'body': 'Body'};

      when(mockClient.post(
        Uri.parse('${ApiService.baseUrl}/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      )).thenAnswer((_) async => http.Response(json.encode(response), 201));

      final createdPost = await apiService.createPost(post);

      expect(createdPost.id, equals(1));
      expect(createdPost.title, equals('Test'));
    });

    test('updatePost returns updated post', () async {
      final post = Post(id: 1, userId: 1, title: 'Updated', body: 'Body');
      final response = {
        'id': 1,
        'userId': 1,
        'title': 'Updated',
        'body': 'Body'
      };

      when(mockClient.put(
        Uri.parse('${ApiService.baseUrl}/posts/1'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      )).thenAnswer((_) async => http.Response(json.encode(response), 200));

      final updatedPost = await apiService.updatePost(post);

      expect(updatedPost.title, equals('Updated'));
    });

    test('throws exception on error response', () {
      when(mockClient.get(Uri.parse('${ApiService.baseUrl}/posts')))
          .thenAnswer((_) async => http.Response('Error', 500));

      expect(() => apiService.getPosts(), throwsException);
    });
  });
}
