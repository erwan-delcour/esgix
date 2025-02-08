import 'package:esgix/logic/blocs/user_bloc/user_bloc.dart';
import 'package:esgix/presentation/screens/create_comment_screen.dart';
import 'package:esgix/presentation/screens/edit_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/post_bloc/post_bloc.dart';
import '../../logic/blocs/post_bloc/post_state.dart';
import '../../logic/blocs/post_bloc/post_event.dart';
import '../../data/models/post.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {

  // @override
  // void dispose() {
  //   context.read<PostBloc>().add(const ClearCommentsEvent());
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final post = ModalRoute.of(context)!.settings.arguments as Post;
    final currentUser = context.read<UserBloc>().state.user?.username;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostBloc>().add(LoadCommentsEvent(postId: post.id));
    });


    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final postBloc = context.read<PostBloc>();
            postBloc.add(const ClearCommentsEvent());
            postBloc.add(const RefreshPostsEvent());
            if(currentUser != null) {
              postBloc.add(LoadUserLikedPostsEvent());
            }
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<PostBloc, PostState>(
          listener: (context, state) {
            if (state.status == PostStatus.success) {
              final postBloc = context.read<PostBloc>();
              final lastEvent = postBloc.state.lastEvent;

              if (lastEvent is UpdatePostEvent) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Post mis à jour avec succès.")),
                );
                Navigator.pop(context, state.posts);
              }
            } else if (state.status == PostStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Erreur lors de la mise à jour du post.")),
              );
            }
          },
          child: SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.content, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              if (post.imageUrl != null) Image.network(post.imageUrl!),
              const SizedBox(height: 16),
              Text('Auteur: ${post.authorUsername}'),
              const SizedBox(height: 16),
              if (currentUser == post.authorUsername)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPostScreen(
                            postId: post.id,
                            initialContent: post.content,
                            initialImageUrl: post.imageUrl,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit the Post"),
                  ),
                ),
              const SizedBox(height: 16),
              if (currentUser == post.authorUsername)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<PostBloc>().add(DeletePostEvent(post.id));
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text("Supprimer le Post"),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateCommentScreen(parentId: post.id),
                    ),
                  );
                },
                child: const Text('Ajouter un commentaire'),
              ),
              const SizedBox(height: 16),
              const Text("Commentaires",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  if (state.status == PostStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.status == PostStatus.error) {
                    return const Center(
                        child:
                        Text("Erreur lors du chargement des commentaires"));
                  } else if (state.comments.isEmpty) {
                    return const Center(
                        child: Text("Aucun commentaire pour le moment."));
                  }

                  final comments =
                  state.comments.where((p) => p.parentId == post.id).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(comment.authorUsername,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  if (comment.authorUsername == currentUser)
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        final postBloc =
                                        context.read<PostBloc>();

                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Confirmation"),
                                            content: const Text(
                                                "Voulez-vous vraiment supprimer ce commentaire ?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text("Annuler"),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text("Supprimer"),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          postBloc.add(DeleteCommentEvent(comment
                                              .id)); // ✅ On utilise postBloc ici, pas context.read()
                                        }
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(comment.content),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
