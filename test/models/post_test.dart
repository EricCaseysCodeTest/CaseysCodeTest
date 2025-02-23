import 'package:flutter_test/flutter_test.dart';
import 'package:json_placeholder_app/models/post.dart';

void main() {
  group('Post', () {
    test('fromJson creates Post instance', () {
      final json = {
        'id': 1,
        'userId': 2,
        'title': 'Test Title',
        'body': 'Test Body',
      };

      final post = Post.fromJson(json);

      expect(post.id, equals(1));
      expect(post.userId, equals(2));
      expect(post.title, equals('Test Title'));
      expect(post.body, equals('Test Body'));
    });

    test('toJson creates correct map', () {
      final post = Post(
        id: 1,
        userId: 2,
        title: 'Test Title',
        body: 'Test Body',
      );

      final json = post.toJson();

      expect(json['id'], equals(1));
      expect(json['userId'], equals(2));
      expect(json['title'], equals('Test Title'));
      expect(json['body'], equals('Test Body'));
    });

    test('copyWith returns new instance with updated values', () {
      final post = Post(
        id: 1,
        userId: 2,
        title: 'Original Title',
        body: 'Original Body',
      );

      final updated = post.copyWith(
        title: 'New Title',
        body: 'New Body',
      );

      expect(updated.id, equals(1));
      expect(updated.userId, equals(2));
      expect(updated.title, equals('New Title'));
      expect(updated.body, equals('New Body'));
    });
  });
}
