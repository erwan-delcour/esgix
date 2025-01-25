class Post {
  final String id;
  final String content;
  final String? imageUrl;
  final String authorId;
  final String authorUsername;
  final int likesCount;
  final List<String> likedBy;

  Post({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.authorId,
    required this.authorUsername,
    this.likesCount = 0,
    this.likedBy = const [],
  });

  Post copyWith({
    String? id,
    String? content,
    String? imageUrl,
    String? authorId,
    String? authorUsername,
    int? likesCount,
    List<String>? likedBy,
  }) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      authorId: authorId ?? this.authorId,
      authorUsername: authorUsername ?? this.authorUsername,
      likesCount: likesCount ?? this.likesCount,
      likedBy: likedBy ?? this.likedBy,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      authorId: json['author']['id'] as String,
      authorUsername: json['author']['username'] as String,
      likesCount: json['likesCount'] as int,
      likedBy: [],
    );
  }
}