import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

class PostProvider extends ChangeNotifier {
  ApiService _apiService = ApiService();
  List<Post> _posts = [];
  final Map<int, List<Comment>> _comments = {};
  bool _isLoading = false;
  bool _isFetching = false;

  // Add these setters for testing
  @visibleForTesting
  set apiService(ApiService service) {
    _apiService = service;
  }

  @visibleForTesting
  set posts(List<Post> value) {
    _posts = value;
  }

  List<Post> get posts => _posts;
  Map<int, List<Comment>> get comments => _comments;
  bool get isLoading => _isLoading;

  Future<void> fetchPosts() async {
    if (_isFetching) return;
    _isFetching = true;
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await _apiService.getPosts();
      notifyListeners();
    } catch (e) {
      _posts = [];
      notifyListeners();
      rethrow;
    } finally {
      _isFetching = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCommentsForPost(int postId) async {
    try {
      final comments = await _apiService.getCommentsForPost(postId);
      _comments[postId] = comments;
      notifyListeners();
    } catch (e) {
      // Remove failed comments from cache
      _comments.remove(postId);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createPost(Post post) async {
    try {
      final newPost = await _apiService.createPost(post);
      _posts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePost(Post post) async {
    try {
      final updatedPost = await _apiService.updatePost(post);
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  void clearComments() {
    _comments.clear();
    notifyListeners();
  }
}
