import '../datasources/api_service.dart';
import '../models/post.dart';

class PostRepository {
  final ApiService apiService;

  PostRepository(this.apiService);

  Future<List<Post>> fetchPosts(String token) async {
    final data = await apiService.getRequest('/posts', token: token);

    if (data.containsKey('data')) {
      return (data['data'] as List).map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Impossible de charger les posts.');
    }
  }

  Future<void> createPost({
    required String token,
    required String content,
    String? imageUrl,
  }) async {
    await apiService.postRequest(
      '/posts',
      {
        'content': content,
        'imageUrl': imageUrl ?? '',
      },
      token: token,
    );
  }

  Future<void> toggleLikePost({
    required String token,
    required String postId,
  }) async {
    final response = await apiService.postRequest(
      '/likes/$postId',
      {},
      token: token,
    );

    if (response is Map<String, dynamic>) {
      print("Réponse après le like/unlike (Map) : $response");
    } else {
      print("Type de réponse inattendu : ${response.runtimeType}");
      throw Exception(
        "Réponse inattendue pour toggleLikePost. Attendu : Map<String, dynamic>. Reçu : ${response.runtimeType}",
      );
    }
  }

  Future<List<String>> fetchLikedBy({
    required String token,
    required String postId,
  }) async {
    print("=== Fetch Liked By ===");
    var data = await apiService.getRequest(
      '/likes/$postId/users',
      token: token,
    );

    print("Données reçues : $data");

    if (data.containsKey('data')) {
      return (data['data'] as List).map((user) {
        if (user is Map<String, dynamic> && user.containsKey('id')) {
          return user['id'] as String;
        } else {
          print("Utilisateur non valide : $user");
          return null;
        }
      }).whereType<String>().toList();
    } else {
      print("Aucune donnée valide trouvée.");
      return [];
    }
  }
}