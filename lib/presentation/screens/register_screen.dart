import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/blocs/user_bloc/user_bloc.dart';
import '../../logic/blocs/user_bloc/user_event.dart';
import '../../logic/blocs/user_bloc/user_state.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final usernameController = TextEditingController();
    final avatarController = TextEditingController(); // URL optionnelle

    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un compte"),
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
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Nom d'utilisateur"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mot de passe"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: avatarController,
              decoration: const InputDecoration(
                labelText: "URL de l'avatar (optionnel)",
              ),
            ),
            const SizedBox(height: 32),
            BlocConsumer<UserBloc, UserState>(
              listener: (context, state) {
                if (state.status == UserStatus.success) {
                  // Rediriger vers l'accueil après inscription
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
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
                    final username = usernameController.text.trim();
                    final password = passwordController.text.trim();
                    final avatar = avatarController.text.trim();

                    context.read<UserBloc>().add(
                          RegisterUserEvent(
                            email: email,
                            username: username,
                            password: password,
                            avatar: avatar.isEmpty ? null : avatar,
                          ),
                        );
                  },
                  child: const Text("S'inscrire"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}