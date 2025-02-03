import '../datasources/api_service.dart';
import '../models/user.dart';

class UserRepository {
  final ApiService apiService;

  UserRepository(this.apiService);

  Future<User> login(String email, String password) async {
    final data = await apiService.postRequest('/auth/login', {
      'email': email,
      'password': password,
    });

    if (data.containsKey('record') && data.containsKey('token')) {
      return User.fromJson(data);
    } else {
      throw Exception('Authentification échouée : Données manquantes.');
    }
  }

  Future<User> update(String token, String userId, {
    required String username,
    String? avatar,
    String? description,
  }) async {
    
    final updatedUser = User(
      id: userId,
      username: username,
      avatar: avatar,
      description: description,
      email: '', 
      token: token,
    );

    return updatedUser; 
  }

  Future<User> registerUser({
    required String email,
    required String username,
    required String password,
    String? avatar,
  }) async {
    final response = await apiService.postRequest(
      '/auth/register',
      {
        "email": email,
        "username": username,
        "password": password,
        if (avatar != null) "avatar": avatar,
      },
    );

    return User.fromJson(response);
  }
}