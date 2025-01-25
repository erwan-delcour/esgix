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
  final String? parentId;

  const CreatePostEvent({
    required this.content,
    this.imageUrl,
    this.parentId
  });

  @override
  List<Object?> get props => [content, imageUrl, parentId];
}


class UpdatePostEvent extends PostEvent {
  final String postId;
  final String content;
  final String? imageUrl;

  const UpdatePostEvent({
    required this.postId,
    required this.content,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [postId, content, imageUrl];
}

class CreateCommentEvent extends PostEvent {
  final String parentId;
  final String content;

  const CreateCommentEvent({required this.parentId, required this.content});
}

class DeletePostEvent extends PostEvent {
  final String postId;

  const DeletePostEvent(this.postId);

  @override
  List<Object> get props => [postId];
}