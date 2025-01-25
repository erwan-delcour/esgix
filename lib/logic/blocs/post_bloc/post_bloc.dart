import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_event.dart';
import 'post_state.dart';
import '../../../data/repositories/post_repository.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;
  String? userToken;

  PostBloc({
    required this.postRepository,
    this.userToken,
    String? userId,
  }) : super(PostState(userId: userId)) {
    on<LoadPostsEvent>(_onLoadPosts);
    on<CreatePostEvent>(_onCreatePost);
    on<ToggleLikePostEvent>(_onToggleLikePost);
    on<LoadLikedByEvent>(_onLoadLikedBy);
  }

  /// Mise à jour dynamique du token utilisateur
  void updateUser({required String? token, required String? id}) {
    userToken = token;
    emit(state.copyWith(userId: id));
  }

  /// Chargement des Posts
  Future<void> _onLoadPosts(
    LoadPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading));

    try {
      final posts = await postRepository.fetchPosts(userToken ?? '');
      emit(state.copyWith(posts: posts, status: PostStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  /// Création d'un Post
  Future<void> _onCreatePost(
    CreatePostEvent event,
    Emitter<PostState> emit,
  ) async {
    if (userToken == null || userToken!.isEmpty) {
      throw Exception("Veuillez vous connecter avant de créer un post.");
    }

    emit(state.copyWith(status: PostStatus.loading));

    try {
      await postRepository.createPost(
        token: userToken!,
        content: event.content,
        imageUrl: event.imageUrl,
      );

      // Recharger les posts après la création
      final posts = await postRepository.fetchPosts(userToken!);
      emit(state.copyWith(posts: posts, status: PostStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  /// Like/Unlike d'un Post
  Future<void> _onToggleLikePost(
    ToggleLikePostEvent event,
    Emitter<PostState> emit,
  ) async {
    print("=== Toggle Like Post ===");
    print("Post ID : ${event.postId}");
    print("Token utilisateur : $userToken");

    if (userToken == null || userToken!.isEmpty) {
      throw Exception("Veuillez vous connecter avant de liker un post.");
    }

    try {
      await postRepository.toggleLikePost(
        token: userToken!,
        postId: event.postId,
      );

      // Mise à jour immédiate des likes localement
      final updatedPosts = state.posts.map((post) {
        if (post.id == event.postId) {
          final isLiked = post.likedBy.contains(state.userId);
          final updatedLikedBy = isLiked
              ? post.likedBy.where((id) => id != state.userId).toList()
              : [...post.likedBy, state.userId!];

          return post.copyWith(
            likedBy: updatedLikedBy,
            likesCount: isLiked ? post.likesCount - 1 : post.likesCount + 1,
          );
        }
        return post;
      }).toList();

      emit(state.copyWith(posts: updatedPosts, status: PostStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  /// Chargement des utilisateurs ayant liké un post
  Future<void> _onLoadLikedBy(
    LoadLikedByEvent event,
    Emitter<PostState> emit,
  ) async {
    try {
      final likedBy = await postRepository.fetchLikedBy(
        token: userToken!,
        postId: event.postId,
      );

      final updatedPosts = state.posts.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(likedBy: likedBy);
        }
        return post;
      }).toList();

      emit(state.copyWith(posts: updatedPosts, status: PostStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }
}