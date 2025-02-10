import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/blocs/post_bloc/post_bloc.dart';
import '../../logic/blocs/post_bloc/post_event.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un Post"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: "Contenu du Post",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Le contenu est obligatoire.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: "URL de l'Image (optionnelle)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              Center(
                child: ElevatedButton(
                  onPressed: _onCreatePost,
                  child: const Text("Créer le Post"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _onCreatePost() {
    if (_formKey.currentState!.validate()) {
      final content = _contentController.text.trim();
      final imageUrl = _imageUrlController.text.trim();

      context.read<PostBloc>().add(
            CreatePostEvent(
              content: content,
              imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
            ),
          );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Post créé avec succès !"),
        ),
      );
    }
  }
}