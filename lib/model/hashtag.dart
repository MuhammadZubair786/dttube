class Hashtag {
  int? id;
  String? name;
  int? totalUsed;
  int? status;
  String? createdAt;
  String? updatedAt;

  Hashtag({this.id, this.name, this.totalUsed, this.status, this.createdAt, this.updatedAt});

  Hashtag.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    totalUsed = json['total_used'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['total_used'] = this.totalUsed;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
