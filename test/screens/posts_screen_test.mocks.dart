// Mocks generated by Mockito 5.4.5 from annotations
// in json_placeholder_app/test/screens/posts_screen_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;
import 'dart:ui' as _i7;

import 'package:json_placeholder_app/models/comment.dart' as _i5;
import 'package:json_placeholder_app/models/post.dart' as _i4;
import 'package:json_placeholder_app/providers/post_provider.dart' as _i2;
import 'package:json_placeholder_app/services/api_service.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [PostProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockPostProvider extends _i1.Mock implements _i2.PostProvider {
  @override
  set apiService(_i3.ApiService? service) => super.noSuchMethod(
    Invocation.setter(#apiService, service),
    returnValueForMissingStub: null,
  );

  @override
  set posts(List<_i4.Post>? value) => super.noSuchMethod(
    Invocation.setter(#posts, value),
    returnValueForMissingStub: null,
  );

  @override
  List<_i4.Post> get posts =>
      (super.noSuchMethod(
            Invocation.getter(#posts),
            returnValue: <_i4.Post>[],
            returnValueForMissingStub: <_i4.Post>[],
          )
          as List<_i4.Post>);

  @override
  Map<int, List<_i5.Comment>> get comments =>
      (super.noSuchMethod(
            Invocation.getter(#comments),
            returnValue: <int, List<_i5.Comment>>{},
            returnValueForMissingStub: <int, List<_i5.Comment>>{},
          )
          as Map<int, List<_i5.Comment>>);

  @override
  bool get isLoading =>
      (super.noSuchMethod(
            Invocation.getter(#isLoading),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  bool get hasListeners =>
      (super.noSuchMethod(
            Invocation.getter(#hasListeners),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  _i6.Future<void> fetchPosts() =>
      (super.noSuchMethod(
            Invocation.method(#fetchPosts, []),
            returnValue: _i6.Future<void>.value(),
            returnValueForMissingStub: _i6.Future<void>.value(),
          )
          as _i6.Future<void>);

  @override
  _i6.Future<void> fetchCommentsForPost(int? postId) =>
      (super.noSuchMethod(
            Invocation.method(#fetchCommentsForPost, [postId]),
            returnValue: _i6.Future<void>.value(),
            returnValueForMissingStub: _i6.Future<void>.value(),
          )
          as _i6.Future<void>);

  @override
  _i6.Future<void> createPost(_i4.Post? post) =>
      (super.noSuchMethod(
            Invocation.method(#createPost, [post]),
            returnValue: _i6.Future<void>.value(),
            returnValueForMissingStub: _i6.Future<void>.value(),
          )
          as _i6.Future<void>);

  @override
  _i6.Future<void> updatePost(_i4.Post? post) =>
      (super.noSuchMethod(
            Invocation.method(#updatePost, [post]),
            returnValue: _i6.Future<void>.value(),
            returnValueForMissingStub: _i6.Future<void>.value(),
          )
          as _i6.Future<void>);

  @override
  void clearComments() => super.noSuchMethod(
    Invocation.method(#clearComments, []),
    returnValueForMissingStub: null,
  );

  @override
  void addListener(_i7.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i7.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}
