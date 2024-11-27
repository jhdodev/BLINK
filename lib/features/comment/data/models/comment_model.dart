class CommentModel {
  // 댓글 
  final String id;

  // 댓글 작성자 유저 아이디
  final String writerId;

  // 댓글 달린 비디오 아이디
  final String videoId;

  // 댓글 내용
  final String content;

  // 생성일
  final DateTime createdAt;

  // 수정일
  final DateTime updatedAt;

  CommentModel({
    required this.id,
    required this.writerId,
    required this.videoId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON -> CommentModel
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      writerId: json['writer_id'],
      videoId: json['video_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // CommentModel -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'writer_id': writerId,
      'video_id': videoId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
