import 'package:equatable/equatable.dart';
import '../../../data/models/post.dart';

enum PostStatus { initial, loading, success, error }

class PostState extends Equatable {
  final List<Post> posts;
  final PostStatus status;
  final String? errorMessage;
  final String? userId;
  final Post? updatedPost;

  const PostState({
    this.posts = const [],
    this.status = PostStatus.initial,
    this.errorMessage,
    this.userId,
    this.updatedPost,
  });

  PostState copyWith({
    List<Post>? posts,
    PostStatus? status,
    String? errorMessage,
    String? userId,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [posts, status, errorMessage, userId];
}