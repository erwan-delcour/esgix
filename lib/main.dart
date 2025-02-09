import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'data/datasources/api_service.dart';
import 'data/repositories/post_repository.dart';
import 'data/repositories/user_repository.dart';
import 'logic/blocs/post_bloc/post_bloc.dart';
import 'logic/blocs/post_bloc/post_event.dart';
import 'logic/blocs/user_bloc/user_bloc.dart';
import 'presentation/screens/edit_profile_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/post_detail_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/create_post_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';

void main() {
  final apiService = ApiService(http.Client());

  runApp(MyApp(
    postRepository: PostRepository(apiService),
    userRepository: UserRepository(apiService),
  ));
}

class MyApp extends StatelessWidget {
  final PostRepository postRepository;
  final UserRepository userRepository;

  const MyApp({
    super.key,
    required this.postRepository,
    required this.userRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: postRepository),
          RepositoryProvider.value(value: userRepository),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => UserBloc(
                userRepository: context.read<UserRepository>(),
              ),
            ),
            BlocProvider(
              create: (context) {
                final userBloc = context.read<UserBloc>();
                return PostBloc(
                  postRepository: context.read<PostRepository>(),
                  userToken: userBloc.state.user?.token ?? '',
                  userId: userBloc.state.user?.id,
                )..add(LoadPostsEvent());
              },
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ESGIX',
            theme: _darkTheme, // Applique le thème sombre directement
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/postDetail': (context) => const PostDetailScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/createPost': (context) => const CreatePostScreen(),
              '/login': (context) => const LoginScreen(),
              '/editProfile': (context) => const EditProfileScreen(),
              '/register': (context) => const RegisterScreen(),
            },
          ),
        )
    );
  }
}

// 🌑 Thème sombre personnalisé
final ThemeData _darkTheme = ThemeData(
  colorScheme: ColorScheme.dark(
    primary: const Color.fromARGB(255, 183, 58, 100),
    secondary: Colors.purpleAccent,
    background: Colors.black,
    surface: Colors.grey[900]!,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor:  Color.fromARGB(255, 183, 58, 100),
    foregroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.black,
  iconTheme: const IconThemeData(color: Colors.white),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white), 
    bodyMedium: TextStyle(color: Colors.white), 
    titleLarge: TextStyle(color: Colors.white), 
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: const Color.fromARGB(255, 183, 58, 100), 
  ),
);