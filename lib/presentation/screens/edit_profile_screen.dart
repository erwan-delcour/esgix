import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/user_bloc/user_bloc.dart';
import '../../logic/blocs/user_bloc/user_event.dart';

class EditProfileScreen extends StatefulWidget {
  final String username;
  final String avatar;
  final String description;

  const EditProfileScreen({
    super.key,
    required this.username,
    required this.avatar,
    required this.description,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _usernameController = TextEditingController();
  final _avatarController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.username;
    _avatarController.text = widget.avatar;
    _descriptionController.text = widget.description;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _avatarController,
              decoration: const InputDecoration(labelText: 'Avatar URL'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _onUpdateProfile,
              child: const Text('Valider les modifications'),
            ),
          ],
        ),
      ),
    );
  }

  void _onUpdateProfile() {
      final username = _usernameController.text.trim();
      final avatar = _avatarController.text.trim();
      final description = _descriptionController.text.trim();

      context.read<UserBloc>().add(
        UpdateUserEvent(
          username: username,
          avatar: avatar,
          description: description,
        ),
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Données mises à jour avec succès."),
        ),
      );
    
  }
}
