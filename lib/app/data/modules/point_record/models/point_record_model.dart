// To parse this JSON data, do
//
//     final pointRecordModel = pointRecordModelFromJson(jsonString);

import 'dart:convert';

PointRecordModel pointRecordModelFromJson(String str) => PointRecordModel.fromJson(json.decode(str));

String pointRecordModelToJson(PointRecordModel data) => json.encode(data.toJson());

class PointRecordModel {
  String? id;
  DateTime? date;
  int? points;
  DateTime? checkInTime;
  String? type;
  String? employeeId;
  DateTime? createdAt;

  PointRecordModel({this.id, this.date, this.points, this.checkInTime, this.type, this.employeeId, this.createdAt});

  factory PointRecordModel.fromJson(Map<String, dynamic> json) => PointRecordModel(
    id: json["id"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    points: json["points"],
    checkInTime: json["checkInTime"] == null ? null : DateTime.parse(json["checkInTime"]),
    type: json["type"],
    employeeId: json["employeeId"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date?.toIso8601String(),
    "points": points,
    "checkInTime": checkInTime?.toIso8601String(),
    "type": type,
    "employeeId": employeeId,
    "createdAt": createdAt?.toIso8601String(),
  };
}
