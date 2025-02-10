import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/post_bloc/post_bloc.dart';
import '../../logic/blocs/post_bloc/post_state.dart';
import '../../logic/blocs/post_bloc/post_event.dart';
import '../../logic/blocs/user_bloc/user_bloc.dart';
import '../../data/models/post.dart';
import 'edit_post_screen.dart';
import 'create_comment_screen.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final post = ModalRoute.of(context)!.settings.arguments as Post;
    final currentUser = context.read<UserBloc>().state.user?.username;
    final currentUserId = context.read<UserBloc>().state.user?.id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostBloc>().add(LoadCommentsEvent(postId: post.id));
    });

    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state.status == PostStatus.updated) {
          Future.delayed(const Duration(seconds: 1), () {
            context.read<PostBloc>().add(RefreshPostEvent(postId: post.id));
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Post Details", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color.fromARGB(255, 183, 58, 100),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              final postBloc = context.read<PostBloc>();
              postBloc.add(const ClearCommentsEvent());
              postBloc.add(const RefreshPostsEvent());
              if (currentUser != null) {
                postBloc.add(LoadUserLikedPostsEvent());
              }
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                final updatedPost = state.posts.firstWhere(
                  (p) => p.id == post.id, 
                  orElse: () => post,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(updatedPost.content, style: const TextStyle(fontSize: 18, color: Colors.white)),
                    const SizedBox(height: 16),
                    if (updatedPost.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(updatedPost.imageUrl!, fit: BoxFit.cover),
                      ),
                    const SizedBox(height: 16),
                    Text('Auteur: ${updatedPost.authorUsername}', style: TextStyle(color: Colors.grey[400])),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (currentUserId == updatedPost.authorId)
                          IconButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditPostScreen(post: updatedPost),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit, color: Colors.orangeAccent, size: 30),
                          ),
                        if (currentUserId == post.authorId)
                          IconButton(
                            onPressed: () {
                              context.read<PostBloc>().add(DeletePostEvent(post.id));
                              context.read<PostBloc>().add(const RefreshPostsEvent());
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                          ),
                        if (currentUser != null)
                          IconButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateCommentScreen(parentId: post.id),
                                ),
                              );
                            },
                            icon: const Icon(Icons.comment, color: Colors.green, size: 30),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Commentaires", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    BlocBuilder<PostBloc, PostState>(
                      builder: (context, state) {
                        if (state.status == PostStatus.loading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state.status == PostStatus.error) {
                          return const Center(child: Text("Erreur lors du chargement des commentaires"));
                        } else if (state.comments.isEmpty) {
                          return const Center(child: Text("Aucun commentaire pour le moment."));
                        }

                        final comments = state.comments.where((p) => p.parentId == post.id).toList();

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Colors.grey, width: 0.5),
                              ),
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(comment.authorUsername,
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                        if (comment.authorId == currentUserId)
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () async {
                                              final postBloc = context.read<PostBloc>();
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text("Confirmation"),
                                                  content: const Text(
                                                      "Voulez-vous vraiment supprimer ce commentaire ?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, false),
                                                      child: const Text("Annuler"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, true),
                                                      child: const Text("Supprimer"),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                postBloc.add(DeleteCommentEvent(comment.id));
                                              }
                                            },
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(comment.content, style: const TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}