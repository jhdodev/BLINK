class UserModel {
  // 유저 아이디
  final String id;

  // 유저 이메일
  final String email;

  // 유저 이름
  final String name;

  // 프로필 이미지 url
  final String? profileImageUrl;

  // 팔로잉 리스트
  final List<String>? followingList;

  // 팔로워 리스트
  final List<String>? followerList;

  // 추천인 아이디
  final String? recommendId;

  // 포인트 // 시청 시간 혜택?
  final int? point;

  // 생성일
  final DateTime createdAt;

  // 수정일
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    this.followingList,
    this.followerList,
    this.recommendId,
    this.point,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON -> UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      profileImageUrl: json['profile_image_url'],
      followingList: (json['following_list'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      followerList: (json['follower_list'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      recommendId: json['recommend_id'],
      point: json['point'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // UserModel -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_image_url': profileImageUrl,
      'following_list': followingList,
      'follower_list': followerList,
      'recommend_id': recommendId,
      'point': point,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
