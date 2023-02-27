class CommonMessageResponse {
  String? message;
  int? commentId;

  CommonMessageResponse({this.message, this.commentId});

  factory CommonMessageResponse.fromJson(Map<String, dynamic> json) {
    return CommonMessageResponse(
      message: json['message'],
      commentId: json['comment_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['comment_id'] = this.commentId;

    return data;
  }
}
