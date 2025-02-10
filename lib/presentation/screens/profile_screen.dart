import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/blocs/user_bloc/user_bloc.dart';
import '../../logic/blocs/user_bloc/user_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state.status == UserStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == UserStatus.error) {
            return Center(
              child: Text(
                "Error: ${state.errorMessage}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state.user == null) {
            return const Center(child: Text("User not found."));
          }

          final user = state.user!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                user.avatar != null && user.avatar!.isNotEmpty
                    ? CircleAvatar(radius: 100,
                      backgroundImage: NetworkImage(user.avatar!),
                    )
                    : const Icon(Icons.account_circle, size: 100),
                
                const SizedBox(height: 30),
                Text(
                  "Username : ${user.username}",
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  "Email : ${user.email}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Description : ${user.description?.isNotEmpty == true ? user.description! : 'Aucune description'}",
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/editProfile');
                    },
                    child: const Text("Edit Profile"),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
