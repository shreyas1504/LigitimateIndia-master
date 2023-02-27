class PostMediaModel {
  int? id;
  String? type;
  String? url;

  PostMediaModel({this.id, this.type, this.url});

  factory PostMediaModel.fromJson(Map<String, dynamic> json) {
    return PostMediaModel(
      id: json['id'],
      type: json['type'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['url'] = this.url;
    return data;
  }
}
