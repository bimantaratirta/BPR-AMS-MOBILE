// To parse this JSON data, do
//
//     final adminModel = adminModelFromJson(jsonString);

import 'dart:convert';

AdminModel adminModelFromJson(String str) => AdminModel.fromJson(json.decode(str));

String adminModelToJson(AdminModel data) => json.encode(data.toJson());

class AdminModel {
  String? id;
  String? name;
  String? email;
  String? password;
  String? role;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  AdminModel({this.id, this.name, this.email, this.password, this.role, this.status, this.createdAt, this.updatedAt});

  factory AdminModel.fromJson(Map<String, dynamic> json) => AdminModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    password: json["password"],
    role: json["role"],
    status: json["status"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "password": password,
    "role": role,
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
