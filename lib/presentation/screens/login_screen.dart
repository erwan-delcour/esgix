import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/blocs/user_bloc/user_bloc.dart';
import '../../logic/blocs/user_bloc/user_event.dart';
import '../../logic/blocs/user_bloc/user_state.dart';
import '../../logic/blocs/post_bloc/post_bloc.dart';
import '../../logic/blocs/post_bloc/post_event.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Se connecter"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mot de passe"),
            ),
            const SizedBox(height: 32),
            BlocConsumer<UserBloc, UserState>(
              listener: (context, state) {
                if (state.status == UserStatus.success) {
                  final user = state.user;
                  if (user != null) {
                    // Mettre à jour PostBloc avec le token et l'ID utilisateur
                    final postBloc = context.read<PostBloc>();
                    postBloc.updateUser(token: user.token, id: user.id);

                    // Charger les posts après mise à jour
                    postBloc.add(LoadPostsEvent());
                  }

                  // Naviguer vers la page d'accueil
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (route) => false,
                  );
                } else if (state.status == UserStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.errorMessage ?? "Erreur inconnue",
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == UserStatus.loading) {
                  return const CircularProgressIndicator();
                }

                return ElevatedButton(
                  onPressed: () {
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();

                    context.read<UserBloc>().add(
                          LoginUserEvent(
                            email: email,
                            password: password,
                          ),
                        );
                  },
                  child: const Text("Se connecter"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}