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
}