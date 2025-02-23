import 'package:flutter_test/flutter_test.dart';
import 'package:json_placeholder_app/models/comment.dart';

void main() {
  group('Comment', () {
    test('fromJson creates Comment instance', () {
      final json = {
        'id': 1,
        'postId': 2,
        'name': 'Test Name',
        'email': 'test@test.com',
        'body': 'Test Body',
      };

      final comment = Comment.fromJson(json);

      expect(comment.id, equals(1));
      expect(comment.postId, equals(2));
      expect(comment.name, equals('Test Name'));
      expect(comment.email, equals('test@test.com'));
      expect(comment.body, equals('Test Body'));
    });

    test('toJson creates correct map', () {
      final comment = Comment(
        id: 1,
        postId: 2,
        name: 'Test Name',
        email: 'test@test.com',
        body: 'Test Body',
      );

      final json = comment.toJson();

      expect(json['id'], equals(1));
      expect(json['postId'], equals(2));
      expect(json['name'], equals('Test Name'));
      expect(json['email'], equals('test@test.com'));
      expect(json['body'], equals('Test Body'));
    });
  });
}
