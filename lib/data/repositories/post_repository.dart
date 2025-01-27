import '../datasources/api_service.dart';
import '../models/post.dart';

class PostRepository {
  final ApiService apiService;

  PostRepository(this.apiService);

  Future<List<Post>> fetchPosts(String? token) async {
    final data = await apiService.getRequest('/posts', token: token);

    if (data.containsKey('data')) {
      final posts = (data['data'] as List).map((post) => Post.fromJson(post)).toList();
      return posts;
    } else {
      throw Exception('Impossible de charger les posts.');
    }
  }

  Future<List<Post>> fetchPostsWithPagination({
    required String? token,
    required int page,
    required int offset,
  }) async {
    final data = await apiService.getRequest(
      '/posts?page=$page&offset=$offset',
      token: token,
    );

    if (data.containsKey('data')) {
      return (data['data'] as List).map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Impossible de charger les posts.');
    }
  }

  Future<List<Post>> fetchComments(String token, String parentId) async {
    final data = await apiService.getRequest('/posts?parent=$parentId', token: token);

    if (data.containsKey('data')) {
      final comments = (data['data'] as List).map((post) => Post.fromJson(post)).toList();
      
      for (var comment in comments) {
        print('Comment ID: ${comment.id}');
        print('Content: ${comment.content}');
        print('Image URL: ${comment.imageUrl}');
        print('---');
      }

      return comments;
    } else {
      throw Exception('Impossible de charger les commentaires.');
    }
  }

Future<void> createPost({
  required String token,
  required String content,
  String? imageUrl,
  String? parentId, 
}) async {

  final requestData = {
    'content': content,
    'imageUrl': imageUrl ?? '',
    'parent': parentId ?? '', 
  };

  await apiService.postRequest(
    '/posts',
    requestData,
    token: token,
  );
}

  Future<void> updatePost({
    required String token,
    required String id,
    required String content,
    String? imageUrl,
  }) async {
    await apiService.putRequest(
      '/posts/$id',
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

  Future<void> deletePost(String token, String postId) async {
    final response = await apiService.deleteRequest('/posts/$postId', token: token);

    if (response.statusCode != 200) {
      throw Exception('Impossible de supprimer le post.');
    }
  }
}