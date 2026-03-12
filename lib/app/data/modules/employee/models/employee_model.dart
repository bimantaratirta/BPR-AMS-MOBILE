// To parse this JSON data, do
//
//     final employeeModel = employeeModelFromJson(jsonString);

import 'dart:convert';

EmployeeModel employeeModelFromJson(String str) => EmployeeModel.fromJson(json.decode(str));

String employeeModelToJson(EmployeeModel data) => json.encode(data.toJson());

class EmployeeModel {
  String? id;
  String? nik;
  String? name;
  String? email;
  String? password;
  dynamic phone;
  String? role;
  dynamic avatar;
  dynamic deviceId;
  dynamic deviceModel;
  dynamic deviceOs;
  String? branchId;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  Branch? branch;
  int? usedAnnualLeave;

  EmployeeModel({
    this.id,
    this.nik,
    this.name,
    this.email,
    this.password,
    this.phone,
    this.role,
    this.avatar,
    this.deviceId,
    this.deviceModel,
    this.deviceOs,
    this.branchId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.branch,
    this.usedAnnualLeave,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
    id: json["id"],
    nik: json["nik"],
    name: json["name"],
    email: json["email"],
    password: json["password"],
    phone: json["phone"],
    role: json["role"],
    avatar: json["avatar"],
    deviceId: json["deviceId"],
    deviceModel: json["deviceModel"],
    deviceOs: json["deviceOs"],
    branchId: json["branchId"],
    isActive: json["isActive"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    branch: json["branch"] == null ? null : Branch.fromJson(json["branch"]),
    usedAnnualLeave: json["usedAnnualLeave"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nik": nik,
    "name": name,
    "email": email,
    "password": password,
    "phone": phone,
    "role": role,
    "avatar": avatar,
    "deviceId": deviceId,
    "deviceModel": deviceModel,
    "deviceOs": deviceOs,
    "branchId": branchId,
    "isActive": isActive,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "branch": branch?.toJson(),
    "usedAnnualLeave": usedAnnualLeave,
  };
}

class Branch {
  String? id;
  String? name;
  String? address;
  double? latitude;
  double? longitude;
  int? radius;
  bool? isActive;

  Branch({this.id, this.name, this.address, this.latitude, this.longitude, this.radius, this.isActive});

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
    id: json["id"],
    name: json["name"],
    address: json["address"],
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    radius: json["radius"],
    isActive: json["isActive"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
    "radius": radius,
    "isActive": isActive,
  };
}
