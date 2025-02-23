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
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }

  Future<List<Comment>> getCommentsForPost(int postId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/posts/$postId/comments'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.statusCode}');
    }
  }

  Future<Post> createPost(Post post) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/posts'),
      body: json.encode({
        'title': post.title,
        'body': post.body,
        'userId': post.userId,
      }),
      headers: {
        'Content-type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 201) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create post: ${response.statusCode}');
    }
  }

  Future<Post> updatePost(Post post) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/posts/${post.id}'),
      body: json.encode({
        'id': post.id,
        'title': post.title,
        'body': post.body,
        'userId': post.userId,
      }),
      headers: {
        'Content-type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update post: ${response.statusCode}');
    }
  }
}
