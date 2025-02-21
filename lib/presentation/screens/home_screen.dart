import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/post_bloc/post_bloc.dart';
import '../../logic/blocs/post_bloc/post_event.dart';
import '../../logic/blocs/post_bloc/post_state.dart';
import '../../logic/blocs/user_bloc/user_bloc.dart';
import '../../logic/blocs/user_bloc/user_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Set<String> loadedLikes = {};

    return Scaffold(
      appBar: AppBar(
        title: const Text("ESGIX"),
        actions: [
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state.user == null) {
                return TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    "Se connecter",
                    style: TextStyle(color: Colors.black),
                  ),
                );
              } else {
                final user = state.user;
                return IconButton(
                  icon: user != null &&
                          user.avatar != null &&
                          user.avatar!.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(user.avatar!),
                        )
                      : const Icon(Icons.account_circle),
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state.status == PostStatus.loading && state.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == PostStatus.error) {
            return Center(
              child: Text(
                "Erreur: ${state.errorMessage}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state.posts.isEmpty) {
            return const Center(child: Text("Aucun post disponible."));
          }

          final posts = state.posts;
          final currentUserId = context.read<UserBloc>().state.user?.id;

          return RefreshIndicator(
            onRefresh: () async {
              final postBloc = context.read<PostBloc>();
              postBloc.add(const RefreshPostsEvent());

              final currentUserId = context.read<UserBloc>().state.user?.id;
              if (currentUserId != null) {
                postBloc.add(
                    LoadUserLikedPostsEvent()); 
              }
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification &&
                    scrollNotification.metrics.extentAfter < 500 &&
                    !state.hasReachedMax &&
                    state.status != PostStatus.loading) {
                  context.read<PostBloc>().add(LoadPostsEvent());
                }
                return false;
              },
              child: ListView.builder(
                itemCount:
                    state.hasReachedMax ? posts.length : posts.length + 1,
                itemBuilder: (context, index) {
                  if (index >= posts.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final post = posts[index];

                  if (currentUserId != null && !loadedLikes.contains(post.id)) {
                    loadedLikes.add(post.id);
                    context
                        .read<PostBloc>()
                        .add(LoadLikedByEvent(postId: post.id));
                  }

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                          Image.network(
                            post.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image,
                                size: 100,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ListTile(
                          title: Text(
                            post.content,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "@${post.authorUsername}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.comment,
                                      color: Colors.grey, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    post.commentsCount.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                  width:
                                      16),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      (post.likedBy.contains(currentUserId) ||
                                      state.likedPostIds.contains(post.id))
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: (post.likedBy.contains(currentUserId) ||
                                      state.likedPostIds.contains(post.id))
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      context.read<PostBloc>().add(
                                            ToggleLikePostEvent(
                                                postId: post.id),
                                          );
                                    },
                                  ),
                                  Text(
                                    post.likesCount.toString(),
                                    style: TextStyle(
                                      color: (post.likedBy.contains(currentUserId) ||
                                      state.likedPostIds.contains(post.id))
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/postDetail',
                            arguments: post,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state.user != null) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/createPost');
              },
              child: const Icon(Icons.add),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
