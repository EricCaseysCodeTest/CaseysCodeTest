import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:json_placeholder_app/providers/post_provider.dart';

Widget createProviderTestWidget({
  required PostProvider postProvider,
  required Widget child,
}) {
  return MaterialApp(
    home: ChangeNotifierProvider<PostProvider>.value(
      value: postProvider,
      child: child,
    ),
  );
}
