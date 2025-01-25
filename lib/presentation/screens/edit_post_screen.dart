import 'package:flutter/material.dart';

class EditPostScreen extends StatefulWidget {
  final String postId;
  final String initialContent;
  final String? initialImageUrl;

  const EditPostScreen({
    super.key,
    required this.postId,
    required this.initialContent,
    this.initialImageUrl,
  });

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.initialContent;
    _imageUrlController.text = widget.initialImageUrl ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Post"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: "Contenu"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Le contenu est requis";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: "URL de l'image (optionnelle)"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onUpdatePost,
                child: const Text("Mettre à jour le Post"),
              )
              ,
            ],
          ),
        ),
      ),
    );
  }

  void _onUpdatePost() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedContent = _contentController.text.trim();
      final updatedImageUrl = _imageUrlController.text.trim();

      Navigator.pop(context, {
        'content': updatedContent,
        'imageUrl': updatedImageUrl,
      });
    }
  }
}