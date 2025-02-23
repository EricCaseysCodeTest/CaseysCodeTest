import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../models/post.dart';
import 'create_post_screen.dart';
import 'edit_post_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch posts when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final posts = postProvider.posts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Note: This is a demo app using JSONPlaceholder API. New posts are only stored locally.',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => postProvider.fetchPosts(),
              child: postProvider.error != null
                  ? Center(
                      child: Text('Error: ${postProvider.error}'),
                    )
                  : postProvider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            return PostCard(post: posts[index]);
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePostScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(
          post.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(post.body),
        children: [
          CommentsSection(postId: post.id!),
          OverflowBar(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatePostScreen(post: post),
                    ),
                  );
                },
                child: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CommentsSection extends StatefulWidget {
  final int postId;

  const CommentsSection({super.key, required this.postId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchComments();
    });
  }

  Future<void> _fetchComments() async {
    try {
      await context.read<PostProvider>().fetchCommentsForPost(widget.postId);
    } catch (e) {
      setState(() {
        _error = 'Failed to load comments';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text(_error!)),
      );
    }

    final comments = context.watch<PostProvider>().comments[widget.postId];

    if (comments == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return ListTile(
          title: Text(comment.name),
          subtitle: Text(comment.body),
          leading: const Icon(Icons.comment),
        );
      },
    );
  }
}
