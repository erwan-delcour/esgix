import '../datasources/api_service.dart';
import '../models/post.dart';

class PostRepository {
  final ApiService apiService;

  PostRepository(this.apiService);

  Future<List<Post>> fetchPosts(String token) async {
    final data = await apiService.getRequest('/posts', token: token);

    if (data.containsKey('data')) {
      final posts = (data['data'] as List).map((post) => Post.fromJson(post)).toList();
      
      // Afficher les détails de chaque post dans la console
      // for (var post in posts) {
      //   print('Post ID: ${post.id}');
      //   print('Content: ${post.content}');
      //   print('Image URL: ${post.imageUrl}');
      //   print('Parent ID: ${post.parentId}');
      //   print('---');
      // }

      return posts;
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

  Future<void> deletePost(String token, String postId) async {
    final response = await apiService.deleteRequest('/posts/$postId', token: token);

    if (response.statusCode != 200) {
      throw Exception('Impossible de supprimer le post.');
    }
  }
}