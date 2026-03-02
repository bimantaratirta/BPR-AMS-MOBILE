// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String? id;
  String? name;
  String? username;
  String? role;
  Region? region;
  Branch? branch;
  Supervisor? supervisor;
  String? regionId;
  String? branchId;
  String? supervisorId;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  UserModel({
    this.id,
    this.name,
    this.username,
    this.role,
    this.region,
    this.branch,
    this.supervisor,
    this.regionId,
    this.branchId,
    this.supervisorId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    name: json["name"],
    username: json["username"],
    role: json["role"],
    region: json["region"] == null ? null : Region.fromJson(json["region"]),
    branch: json["branch"] == null ? null : Branch.fromJson(json["branch"]),
    supervisor: json["supervisor"] == null ? null : Supervisor.fromJson(json["supervisor"]),
    regionId: json["region_id"],
    branchId: json["branch_id"],
    supervisorId: json["supervisor_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"] == null ? null : DateTime.parse(json["deleted_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "username": username,
    "role": role,
    "region": region?.toJson(),
    "branch": branch?.toJson(),
    "supervisor": supervisor?.toJson(),
    "region_id": regionId,
    "branch_id": branchId,
    "supervisor_id": supervisorId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt?.toIso8601String(),
  };
}

class Branch {
  String? id;
  String? branch;

  Branch({this.id, this.branch});

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(id: json["id"], branch: json["branch"]);

  Map<String, dynamic> toJson() => {"id": id, "branch": branch};
}

class Region {
  String? id;
  String? region;

  Region({this.id, this.region});

  factory Region.fromJson(Map<String, dynamic> json) => Region(id: json["id"], region: json["region"]);

  Map<String, dynamic> toJson() => {"id": id, "region": region};
}

class Supervisor {
  String? id;
  String? name;

  Supervisor({this.id, this.name});

  factory Supervisor.fromJson(Map<String, dynamic> json) => Supervisor(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
