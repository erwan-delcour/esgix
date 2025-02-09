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
    on<RefreshPostsEvent>(_onRefreshPosts);
    on<CreatePostEvent>(_onCreatePost);
    on<ToggleLikePostEvent>(_onToggleLikePost);
    on<LoadLikedByEvent>(_onLoadLikedBy);
    on<UpdatePostEvent>(_onUpdatePost);
    on<LoadCommentsEvent>(_onLoadComments);
    on<CreateCommentEvent>(_onCreateComment);
    on<DeletePostEvent>(_onDeletePostEvent);
    on<DeleteCommentEvent>(_onDeleteCommentEvent);
    on<LoadUserLikedPostsEvent>(_onLoadUserLikedPosts);
    on<ClearCommentsEvent>((event, emit) {
      emit(state.copyWith(comments: [])); 
    });
  }

  void updateUser({required String token, required String? id}) {
    userToken = token;
    emit(state.copyWith(userId: id));

    if (id != null) {
      add(LoadUserLikedPostsEvent());
    }
  }

  Future<void> _onLoadPosts(
    LoadPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    if (state.hasReachedMax) return; 
    emit(state.copyWith(status: PostStatus.loading));

    try {
      final posts = await postRepository.fetchPostsWithPagination(
        token: userToken,
        page: currentPage,
        offset: offset,
      );

      if (posts.isEmpty) {
        emit(state.copyWith(hasReachedMax: true, status: PostStatus.success));
      } else {
        emit(state.copyWith(
          posts: [...state.posts, ...posts],
          status: PostStatus.success,
        ));
        currentPage++;
      }
    } catch (error) {
      emit(state.copyWith(status: PostStatus.error, errorMessage: error.toString()));
    }
  }
  Future<void> _onLoadComments(
      LoadCommentsEvent event,
      Emitter<PostState> emit,
      ) async {
    emit(state.copyWith(status: PostStatus.loading));

    try {
      final comments = await postRepository.fetchComments(userToken, event.postId);
      emit(state.copyWith(comments: comments, status: PostStatus.success));
    } catch (error) {
      emit(state.copyWith(status: PostStatus.error, errorMessage: error.toString()));
    }
  }

  Future<void> _onRefreshPost(
    RefreshPostEvent event,
    Emitter<PostState> emit,
  ) async {
    try {
      final updatedPost = await postRepository.fetchPostById(userToken, event.postId);
      final updatedPosts = state.posts.map((post) =>
        post.id == updatedPost.id ? updatedPost : post
      ).toList();

      emit(state.copyWith(posts: updatedPosts, status: PostStatus.success));
    } catch (error) {
      emit(state.copyWith(status: PostStatus.error, errorMessage: error.toString()));
    }
  }

  Future<void> _onRefreshPosts(
    RefreshPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    currentPage = 0; 
    emit(state.copyWith(status: PostStatus.loading, posts: [], hasReachedMax: false));

    try {
      final posts = await postRepository.fetchPostsWithPagination(
        token: userToken,
        page: 0,
        offset: offset,
      );

      emit(state.copyWith(
        posts: posts, 
        status: PostStatus.success,
        likedPostIds: posts
            .where((post) => post.isLiked)
            .map((post) => post.id)
            .toSet(), 
      ));

      currentPage++; 
    } catch (error) {
      emit(state.copyWith(status: PostStatus.error, errorMessage: error.toString()));
    }
  }

  void _onDeleteCommentEvent(DeleteCommentEvent event, Emitter<PostState> emit) async {
    try {
      await postRepository.deletePost(userToken, event.commentId);
      final updatedComments = state.comments.where((comment) => comment.id != event.commentId).toList();

      emit(state.copyWith(comments: updatedComments, status: PostStatus.success));
    } catch (_) {
      emit(state.copyWith(status: PostStatus.error));
    }
  }

  Future<void> _onDeletePostEvent(
      DeletePostEvent event,
      Emitter<PostState> emit,
      ) async {
    try {
      await postRepository.deletePost(userToken, event.postId);
      add(LoadPostsEvent());
    } catch (_) {
      emit(state.copyWith(status: PostStatus.error));
    }
  }


  Future<void> _onLoadUserLikedPosts(
      LoadUserLikedPostsEvent event,
      Emitter<PostState> emit,
      ) async {
    if (state.userId == null) return;

    try {
      final likedPostIds = await postRepository.fetchUserLikes(
        token: userToken,
        userId: state.userId!,
      );

      emit(state.copyWith(likedPostIds: likedPostIds.toSet()));
    } catch (error) {
      print("Erreur lors du chargement des posts likés : $error");
    }
  }

  /// Création d'un Post
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

      add(RefreshPostsEvent());
    } catch (error) {
      emit(state.copyWith(status: PostStatus.error, errorMessage: error.toString()));
    }
  }

  /// Like / Unlike d'un Post
  Future<void> _onToggleLikePost(
      ToggleLikePostEvent event,
      Emitter<PostState> emit,
      ) async {
    if (userToken.isEmpty) {
      throw Exception("Veuillez vous connecter avant de liker un post.");
    }

    try {
      await postRepository.toggleLikePost(token: userToken, postId: event.postId);

      // Recharger les posts likés
      add(LoadUserLikedPostsEvent());

      final updatedPosts = state.posts.map((post) {
        if (post.id == event.postId) {
          final isLiked = state.likedPostIds.contains(post.id);
          return post.copyWith(
            likedBy: isLiked
                ? post.likedBy.where((id) => id != state.userId).toList()
                : [...post.likedBy, state.userId!],
            likesCount: isLiked ? post.likesCount - 1 : post.likesCount + 1,
          );
        }
        return post;
      }).toList();

      emit(state.copyWith(posts: updatedPosts, status: PostStatus.success));
    } catch (error) {
      emit(state.copyWith(status: PostStatus.error, errorMessage: error.toString()));
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
      emit(state.copyWith(status: PostStatus.error, errorMessage: error.toString()));
    }
  }

Future<void> _onUpdatePost(
  UpdatePostEvent event,
  Emitter<PostState> emit,
) async {
  print("UpdatePostEvent reçu avec id: ${event.postId}");

  if (userToken.isEmpty) {
    throw Exception("Token utilisateur manquant.");
  }

  emit(state.copyWith(status: PostStatus.loading, lastEvent: event));

  try {
    await postRepository.updatePost(
      token: userToken,
      id: event.postId,
      content: event.content,
      imageUrl: event.imageUrl,
    );

    print("Post mis à jour, état updated");
    emit(state.copyWith(status: PostStatus.updated));

    add(const RefreshPostsEvent()); 
  } catch (error) {
    emit(state.copyWith(status: PostStatus.error, errorMessage: error.toString()));
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

      add(const RefreshPostsEvent());
    } catch (error) {
      emit(state.copyWith(status: PostStatus.error, errorMessage: error.toString()));
    }
  }
}
