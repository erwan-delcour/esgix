import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_event.dart';
import 'post_state.dart';
import '../../../data/repositories/post_repository.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;
  String userToken;

  PostBloc({
    required this.postRepository,
    required this.userToken,
  }) : super(const PostState()) {
    on<LoadPostsEvent>(_onLoadPosts);
    on<CreatePostEvent>(_onCreatePost);
    on<UpdatePostEvent>(_onUpdatePost);
    on<LoadCommentsEvent>(_onLoadComments);
    on<CreateCommentEvent>(_onCreateComment); 
    on<DeletePostEvent>(_onDeletePostEvent);
    on<DeleteCommentEvent>(_onDeleteCommentEvent);
  }
  
  void updateToken(String token) {
    userToken = token;
  }

  Future<void> _onLoadPosts(
    LoadPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading));

    try {
      final posts = await postRepository.fetchPosts(userToken);
      emit(state.copyWith(posts: posts, status: PostStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onLoadComments(
    LoadCommentsEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading));

    try {
      final posts = await postRepository.fetchComments(userToken, event.postId);
      emit(state.copyWith(posts: posts, status: PostStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onDeletePostEvent(DeletePostEvent event, Emitter<PostState> emit) async {
    try {
      await postRepository.deletePost(userToken, event.postId);
      add(LoadPostsEvent());
    } catch (_) {
      emit(state.copyWith(status: PostStatus.error));
    }
  }

  void _onDeleteCommentEvent(DeleteCommentEvent event, Emitter<PostState> emit) async {
    try {
      await postRepository.deletePost(userToken, event.commentId);
      add(LoadCommentsEvent(postId: event.commentId));
    } catch (_) {
      emit(state.copyWith(status: PostStatus.error));
    }
  }

  Future<void> _onCreatePost(
    CreatePostEvent event,
    Emitter<PostState> emit,
  ) async {
    if (userToken.isEmpty) {
      throw Exception("Token utilisateur manquant.");
    }

    emit(state.copyWith(status: PostStatus.loading));

    try {
      await postRepository.createPost(
        token: userToken,
        content: event.content,
        imageUrl: event.imageUrl,
        parentId: event.parentId,
      );

      final posts = await postRepository.fetchPosts(userToken);
      emit(state.copyWith(posts: posts, status: PostStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onUpdatePost(
  UpdatePostEvent event,
  Emitter<PostState> emit,
) async {
  emit(state.copyWith(status: PostStatus.loading, lastEvent: event));

  try {
    await postRepository.updatePost(
      token: userToken,
      id: event.postId,
      content: event.content,
      imageUrl: event.imageUrl,
    );

    final posts = await postRepository.fetchPosts(userToken);
    emit(state.copyWith(posts: posts, status: PostStatus.success, lastEvent: event));
  } catch (error) {
    emit(state.copyWith(
      status: PostStatus.error,
      errorMessage: error.toString(),
      lastEvent: event,
    ));
  }
}
  
  Future<void> _onCreateComment(
    CreateCommentEvent event,
    Emitter<PostState> emit,
  ) async {
    if (userToken.isEmpty) {
      throw Exception("Token utilisateur manquant.");
    }

    emit(state.copyWith(status: PostStatus.loading));

    try {
      await postRepository.createPost(
        token: userToken,
        parentId: event.parentId,
        content: event.content,
      );

      final posts = await postRepository.fetchPosts(userToken);

      emit(state.copyWith(posts: posts, status: PostStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }
}