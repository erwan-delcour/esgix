import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class LoadPostsEvent extends PostEvent {}

class CreatePostEvent extends PostEvent {
  final String content;
  final String? imageUrl;

  const CreatePostEvent({
    required this.content,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [content, imageUrl];
}

class ToggleLikePostEvent extends PostEvent {
  final String postId;

  const ToggleLikePostEvent({required this.postId});

  @override
  List<Object?> get props => [postId];
}

class LoadLikedByEvent extends PostEvent {
  final String postId;

  const LoadLikedByEvent({required this.postId});

  @override
  List<Object?> get props => [postId];
}