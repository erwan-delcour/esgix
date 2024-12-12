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
}