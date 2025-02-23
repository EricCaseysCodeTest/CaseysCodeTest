import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/comment.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  final http.Client _client;

  ApiService([http.Client? client]) : _client = client ?? http.Client();

  Future<List<Post>> getPosts() async {
    final response = await _client.get(Uri.parse('$baseUrl/posts'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<List<Comment>> getCommentsForPost(int postId) async {
    final response =
        await _client.get(Uri.parse('$baseUrl/posts/$postId/comments'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<Post> createPost(Post post) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(post.toJson()),
    );
    if (response.statusCode == 201) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create post');
    }
  }

  Future<Post> updatePost(Post post) async {
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl/posts/${post.id}'),
        body: jsonEncode({
          'title': post.title,
          'body': post.body,
        }),
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // JSONPlaceholder returns the updated fields only, so merge with existing post data
        final responseData = jsonDecode(response.body);
        return Post(
          id: post.id,
          userId: post.userId,
          title: responseData['title'] ?? post.title,
          body: responseData['body'] ?? post.body,
        );
      } else {
        throw Exception('Failed to update post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }
}
