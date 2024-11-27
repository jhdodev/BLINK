class FollowModel {
  final String id;
  final String followerId;
  final String followedId;
  final DateTime createdAt;

  FollowModel({
    required this.id,
    required this.followerId,
    required this.followedId,
    required this.createdAt,
  });

  // JSON -> FollowModel
  factory FollowModel.fromJson(Map<String, dynamic> json) {
    return FollowModel(
      id: json['id'],
      followerId: json['follower_id'],
      followedId: json['followed_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // FollowModel -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_id': followerId,
      'followed_id': followedId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
