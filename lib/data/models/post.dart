class Post {
  final String id;
  final String content;
  final String? imageUrl;
  final String authorId;
  final String createdAt;
  final String updatedAt;
  final String authorUsername;
  final String? authorAvatar;
  final int likesCount;
  final String parentId;
  final int commentsCount;
  bool isLiked;
  final List<String> likedBy;

  Post({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.authorId,
    required this.authorUsername,
    this.likesCount = 0,
    this.likedBy = const [],
    required this.parentId,
    this.authorAvatar,
    required this.commentsCount,
    this.isLiked = false,
  });

  Post copyWith({
    String? id,
    String? content,
    String? imageUrl,
    String? authorId,
    String? parentId,
    String? authorAvatar,
    String? createdAt,
    String? updatedAt,
    String? authorUsername,
    int? commentsCount,
    int? likesCount,
    List<String>? likedBy,
  }) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentId: parentId ?? this.parentId,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      authorId: authorId ?? this.authorId,
      authorUsername: authorUsername ?? this.authorUsername,
      commentsCount: commentsCount ?? this.commentsCount,
      likesCount: likesCount ?? this.likesCount,
      likedBy: likedBy ?? this.likedBy,
    );
  }

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