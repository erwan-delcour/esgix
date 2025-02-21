import 'package:equatable/equatable.dart';
import '../../../data/models/post.dart';
import 'post_event.dart';

enum PostStatus { initial, loading, success, error, updated }

class PostState extends Equatable {
  final List<Post> posts;
  final List<Post> comments;
  final PostStatus status;
  final String? errorMessage;
  final String? userId;
  final Post? updatedPost;
  final PostEvent? lastEvent; 

  final int currentPage;
  final bool hasReachedMax;

  final Set<String> likedPostIds;

  const PostState({
    this.posts = const [],
    this.comments = const [],
    this.status = PostStatus.initial,
    this.errorMessage,
    this.userId,
    this.updatedPost,
    this.currentPage = 0,
    this.hasReachedMax = false,
    this.likedPostIds = const {},
    this.lastEvent,
  });

  PostState copyWith({
    List<Post>? posts,
    List<Post>? comments,
    PostStatus? status,
    String? errorMessage,
    String? userId,
    Post? updatedPost,
    int? currentPage,
    bool? hasReachedMax,
    Set<String>? likedPostIds,
    PostEvent? lastEvent,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      comments: comments ?? this.comments,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      updatedPost: updatedPost ?? this.updatedPost,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      likedPostIds: likedPostIds ?? this.likedPostIds,
      lastEvent: lastEvent ?? this.lastEvent,
    );
  }

  @override
  List<Object?> get props => [
    posts,
    comments,
    status,
    errorMessage,
    userId,
    updatedPost,
    currentPage,
    hasReachedMax,
    lastEvent,
    likedPostIds, 
  ];
}