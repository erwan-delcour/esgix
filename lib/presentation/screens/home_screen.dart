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
    // Suivi des posts pour lesquels les likes ont déjà été chargés
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
                  icon: user != null && user.avatar != null && user.avatar!.isNotEmpty
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
          if (state.status == PostStatus.loading) {
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

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              // Charger les likes si nécessaire et si l'utilisateur est connecté
              if (currentUserId != null && !loadedLikes.contains(post.id)) {
                loadedLikes.add(post.id);
                context.read<PostBloc>().add(LoadLikedByEvent(postId: post.id));
              }

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Affiche l'image si elle existe
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Affiche le nombre de likes
                          Text(
                            post.likesCount.toString(),
                            style: TextStyle(
                              color: currentUserId != null &&
                                      post.likedBy.contains(currentUserId)
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                          // Bouton de like/unlike
                          IconButton(
                            icon: Icon(
                              post.likedBy.contains(currentUserId)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: currentUserId != null &&
                                      post.likedBy.contains(currentUserId)
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              // Toggle like/unlike
                              context.read<PostBloc>().add(
                                    ToggleLikePostEvent(postId: post.id),
                                  );
                            },
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