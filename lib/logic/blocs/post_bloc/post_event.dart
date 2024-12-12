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