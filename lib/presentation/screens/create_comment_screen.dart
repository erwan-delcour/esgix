import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/post_bloc/post_bloc.dart';
import '../../logic/blocs/post_bloc/post_event.dart';
import '../../logic/blocs/user_bloc/user_bloc.dart';

class CreateCommentScreen extends StatefulWidget {
  final String parentId;

  const CreateCommentScreen({
    super.key,
    required this.parentId,
  });

  @override
  State<CreateCommentScreen> createState() => _CreateCommentScreenState();
}

class _CreateCommentScreenState extends State<CreateCommentScreen> {
  final _commentController = TextEditingController();
  final _imageUrlController = TextEditingController(); 
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un commentaire"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: "Contenu du commentaire",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Le contenu est requis";
                  }
                  return null;
                },
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: "URL de l'Image (optionnelle)",
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _onCreateComment,
                child: const Text("Publier"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCreateComment() {
    if (_formKey.currentState?.validate() ?? false) {
      final content = _commentController.text.trim();
      final imageUrl = _imageUrlController.text.trim();

      final postBloc = context.read<PostBloc>();

      postBloc.add(
        CreatePostEvent(
          content: content,
          imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
          parentId: widget.parentId,
        ),
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        postBloc.add(const RefreshPostsEvent());

        if (context.read<UserBloc>().state.user != null) {
          postBloc.add(LoadUserLikedPostsEvent());
        }

        Navigator.pop(context);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Commentaire créé avec succès !"),
        ),
      );
    }
  }
}