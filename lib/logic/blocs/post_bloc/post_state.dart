import 'package:equatable/equatable.dart';
import '../../../data/models/post.dart';
import 'post_event.dart';

enum PostStatus { initial, loading, success, error }

class PostState extends Equatable {
  final List<Post> posts;
  final PostStatus status;
  final String? errorMessage;
  final Post? updatedPost;
  final PostEvent? lastEvent; // Ajout pour suivre l'événement déclencheur

  const PostState({
    this.posts = const [],
    this.status = PostStatus.initial,
    this.errorMessage,
    this.updatedPost,
    this.lastEvent,
  });

  PostState copyWith({
    List<Post>? posts,
    PostStatus? status,
    String? errorMessage,
    Post? updatedPost,
    PostEvent? lastEvent,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      updatedPost: updatedPost ?? this.updatedPost,
      lastEvent: lastEvent ?? this.lastEvent,
    );
  }

  @override
  List<Object?> get props => [posts, status, errorMessage, updatedPost, lastEvent];
}