import 'package:esgix/logic/blocs/user_bloc/user_bloc.dart';
import 'package:esgix/presentation/screens/create_comment_screen.dart';
import 'package:esgix/presentation/screens/edit_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/post_bloc/post_bloc.dart';
import '../../logic/blocs/post_bloc/post_state.dart';
import '../../logic/blocs/post_bloc/post_event.dart';
import '../../data/models/post.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final post = ModalRoute.of(context)!.settings.arguments as Post;
    final currentUser = context.read<UserBloc>().state.user?.username;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<PostBloc, PostState>(
          listener: (context, state) {
            if (state.status == PostStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Post mis à jour avec succès.")),
              );
              Navigator.pop(context, state.posts);
            } else if (state.status == PostStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Erreur lors de la mise à jour du post.")),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.content, style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              if (post.imageUrl != null)
                Image.network(post.imageUrl!),
              SizedBox(height: 16),
              Text('Auteur: ${post.authorUsername}'),
              SizedBox(height: 16),
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
                      
                      if (result != null) {
                        context.read<PostBloc>().add(UpdatePostEvent(
                          postId: post.id,
                          content: result['content'],
                          imageUrl: result['imageUrl'],
                        ));
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit the Post"),
                  ),
                ),
              SizedBox(height: 16),
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
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateCommentScreen(parentId: post.id),
                    ),
                  );
                },
                child: Text('Ajouter un commentaire'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}