import 'package:esgix/logic/blocs/user_bloc/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/user_bloc/user_bloc.dart';
import '../../logic/blocs/user_bloc/user_event.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

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
    final state = context.read<UserBloc>().state;
    if (state.status == UserStatus.success && state.user != null) {
      _usernameController.text = state.user!.username;
      _avatarController.text = state.user!.avatar ?? '';
      _descriptionController.text = state.user!.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state.status == UserStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Données mises à jour avec succès.")),
              );
              Navigator.pop(context);
            } else if (state.status == UserStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Erreur: ${state.errorMessage}")),
              );
            }
          },
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
      ),
    );
  }

  void _onUpdateProfile() async {
    final username = _usernameController.text.trim();
    final avatar = _avatarController.text.trim();
    final description = _descriptionController.text.trim();

    final userBloc = context.read<UserBloc>();
    
    userBloc.add(
      UpdateUserEvent(
        username: username,
        avatar: avatar,
        description: description,
      ),
    );
  }
  
}