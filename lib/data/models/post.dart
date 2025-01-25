class Post {
  final String id;
  final String content;
  final String? imageUrl;
  final String createdAt;
  final String updatedAt;
  final String authorId;
  final String authorUsername;
  final String? authorAvatar;
  final int likesCount;
  final String parentId;
  final int commentsCount;
  bool isLiked;
    

  Post({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.authorId,
    required this.authorUsername,
    required this.parentId,
    this.authorAvatar,
    required this.likesCount,
    required this.commentsCount,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? {};

    return Post(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'].toString().isEmpty ? null : json['imageUrl'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      authorId: author['id'] ?? '',
      parentId: json['parent'] ?? '',
      authorUsername: author['username'] ?? '',
      authorAvatar: author['avatar'].toString().isEmpty ? null : author['avatar'],
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
    );
  }
}