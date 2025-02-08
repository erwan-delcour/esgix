import 'package:esgix/data/models/post.dart';
import 'package:esgix/logic/blocs/post_bloc/post_bloc.dart';
import 'package:esgix/logic/blocs/post_bloc/post_event.dart';
import 'package:esgix/logic/blocs/post_bloc/post_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({
    super.key,
    required this.post,
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
    _contentController.text = widget.post.content;
    _imageUrlController.text = widget.post.imageUrl ?? '';
  }

        @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Edit Post"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocListener<PostBloc, PostState>(
            listener: (context, state) {
              debugPrint("EditPostScreen - Nouvel état : ${state.status}");
              if (state.status == PostStatus.updated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('Post mis à jour', selectionColor: Colors.white,)),
                );
                Navigator.of(context).pop();
              }
            },
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Contenu',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le contenu ne peut pas être vide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL de l\'image (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<PostBloc>().add(
                              UpdatePostEvent(
                                  postId: widget.post.id,
                                  content: _contentController.text,
                                  imageUrl: _imageUrlController.text.isEmpty 
                                      ? null 
                                      : _imageUrlController.text,
                                ),
                            );
                      }
                    },
                    child: const Text('Mettre à jour'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
}