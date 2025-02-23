import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../models/post.dart';
import 'create_post_screen.dart';
import 'edit_post_screen.dart';

class PostsScreen extends StatelessWidget {
  const PostsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              onRefresh: () async {
                await Provider.of<PostProvider>(context, listen: false)
                    .fetchPosts();
              },
              child: Consumer<PostProvider>(
                builder: (context, postProvider, child) {
                  if (postProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (postProvider.error != null) {
                    return Center(child: Text('Error: ${postProvider.error}'));
                  }

                  if (postProvider.posts.isEmpty) {
                    return const Center(child: Text('No posts available'));
                  }

                  return ListView.builder(
                    itemCount: postProvider.posts.length,
                    itemBuilder: (context, index) {
                      final post = postProvider.posts[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(post.title),
                          subtitle: Text(post.body),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final provider = Provider.of<PostProvider>(
                                  context,
                                  listen: false);
                              final updatedPost = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditPostScreen(post: post),
                                ),
                              );
                              if (updatedPost != null) {
                                provider.updatePost(updatedPost as Post);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final provider = Provider.of<PostProvider>(context, listen: false);
          final newPost = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
          if (newPost != null) {
            provider.addPost(newPost as Post);
          }
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
