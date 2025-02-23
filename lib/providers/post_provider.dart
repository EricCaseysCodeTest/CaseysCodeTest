import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

class PostProvider extends ChangeNotifier {
  ApiService _apiService = ApiService();
  List<Post> _posts = [];
  final Map<int, List<Comment>> _comments = {};
  bool _isLoading = false;
  String? _error;
  // Add this to track locally created posts
  final List<Post> _localPosts = [];
  bool _isFetching = false; // Add this flag

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
  String? get error => _error;

  Future<void> fetchPosts() async {
    if (_isFetching) return; // Early return if already fetching
    _isFetching = true;
    try {
      setLoading(true);
      setError(null);
      final fetchedPosts = await _apiService.getPosts();
      // Combine fetched posts with local posts
      _posts = [..._localPosts, ...fetchedPosts];
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
      _isFetching = false;
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

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> addPost(Post post) async {
    try {
      setLoading(true);
      setError(null);
      final newPost = await _apiService.createPost(post);
      // Add to local posts instead of regular posts
      _localPosts.insert(0, newPost);
      _posts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
