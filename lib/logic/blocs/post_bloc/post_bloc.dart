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
    on<CreateCommentEvent>(_onCreateComment); 
    on<DeletePostEvent>(_onDeletePostEvent);
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
      final comments = await postRepository.fetchComments(userToken ,"plscmgec40edvmu");
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
    if (userToken.isEmpty) {
      throw Exception("Token utilisateur manquant.");
    }

    emit(state.copyWith(status: PostStatus.loading));

    try {
    
      await postRepository.updatePost(
        token: userToken,
        id: event.postId,
        content: event.content,
        imageUrl: event.imageUrl,
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