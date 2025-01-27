import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_event.dart';
import 'post_state.dart';
import '../../../data/repositories/post_repository.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;
  String userToken;
  int currentPage = 0; // Page actuelle pour la pagination
  static const int offset = 10; // Taille des résultats par page

  PostBloc({
    required this.postRepository,
    required this.userToken,
    String? userId,
  }) : super(PostState(userId: userId)) {
    on<LoadPostsEvent>(_onLoadPosts);
    on<CreatePostEvent>(_onCreatePost);
    on<ToggleLikePostEvent>(_onToggleLikePost);
    on<LoadLikedByEvent>(_onLoadLikedBy);
    on<UpdatePostEvent>(_onUpdatePost);
    on<CreateCommentEvent>(_onCreateComment);
    on<DeletePostEvent>(_onDeletePostEvent);
    on<RefreshPostsEvent>(_onRefreshPosts); // Nouvelle fonction ajoutée

  }

  /// Mise à jour dynamique du token utilisateur
  void updateUser({required String token, required String? id}) {
    userToken = token;
    emit(state.copyWith(userId: id));
  }

  /// Chargement des Posts avec pagination
  Future<void> _onLoadPosts(
    LoadPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    // Ne pas recharger si on a atteint la fin des posts
    if (state.hasReachedMax) return;

    emit(state.copyWith(status: PostStatus.loading));

    try {
      final posts = await postRepository.fetchPostsWithPagination(
        token: userToken,
        page: currentPage,
        offset: offset,
      );

      if (posts.isEmpty) {
        // Si aucun nouveau post n'est chargé, marquer comme "fin des résultats"
        emit(state.copyWith(hasReachedMax: true, status: PostStatus.success));
      } else {
        emit(state.copyWith(
          posts: [...state.posts, ...posts],
          status: PostStatus.success,
        ));
        currentPage++; // Passer à la page suivante
      }
    } catch (error) {
      emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onRefreshPosts(
    RefreshPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading, hasReachedMax: false));
    currentPage = 0; // Réinitialiser à la première page

    try {
      final posts = await postRepository.fetchPostsWithPagination(
        token: userToken,
        page: 0,
        offset: offset,
      );

      emit(state.copyWith(posts: posts, status: PostStatus.success));
      currentPage++;
      if (state.userId != null) {
        for (final post in posts) {
          add(LoadLikedByEvent(postId: post.id));
        }
      }
    } catch (error) {
      emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onCreatePost(
    CreatePostEvent event,
    Emitter<PostState> emit,
  ) async {
    if (userToken.isEmpty) {
      throw Exception("Veuillez vous connecter avant de créer un post.");
    }

    emit(state.copyWith(status: PostStatus.loading));

    try {
      await postRepository.createPost(
        token: userToken,
        content: event.content,
        imageUrl: event.imageUrl,
        parentId: event.parentId,
      );

      // Recharger les posts après la création
      final posts = await postRepository.fetchPostsWithPagination(
        token: userToken,
        page: 0,
        offset: offset,
      );
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
      // Recharger les posts après la suppression
      add(LoadPostsEvent());
    } catch (_) {
      emit(state.copyWith(status: PostStatus.error));
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

    if (userToken.isEmpty) {
      throw Exception("Veuillez vous connecter avant de liker un post.");
    }

    try {
      await postRepository.toggleLikePost(
        token: userToken,
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
        token: userToken,
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

      final posts = await postRepository.fetchPostsWithPagination(
        token: userToken,
        page: 0,
        offset: offset,
      );

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

      final posts = await postRepository.fetchPostsWithPagination(
        token: userToken,
        page: 0,
        offset: offset,
      );

      emit(state.copyWith(posts: posts, status: PostStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }
}