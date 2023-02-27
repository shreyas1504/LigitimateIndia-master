class MemberModel {
  bool? isAdmin;
  String? userAvatar;
  int? userId;
  String? userName;
  String? mentionName;

  MemberModel({this.isAdmin, this.userAvatar, this.userId, this.userName, this.mentionName});

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      isAdmin: json['is_admin'],
      userAvatar: json['user_avatar'],
      userId: json['user_id'],
      userName: json['user_name'],
      mentionName: json['mention_name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['is_admin'] = this.isAdmin;
    data['user_avatar'] = this.userAvatar;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['mention_name'] = this.mentionName;

    return data;
  }
}
