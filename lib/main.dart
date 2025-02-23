import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/posts_screen.dart';
import 'providers/post_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PostProvider(),
      child: MaterialApp(
        title: 'Casey\'s Code Test',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const PostsScreen(),
      ),
    );
  }
}
