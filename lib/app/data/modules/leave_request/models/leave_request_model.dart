// To parse this JSON data, do
//
//     final leaveRequestModel = leaveRequestModelFromJson(jsonString);

import 'dart:convert';

LeaveRequestModel leaveRequestModelFromJson(String str) => LeaveRequestModel.fromJson(json.decode(str));

String leaveRequestModelToJson(LeaveRequestModel data) => json.encode(data.toJson());

class LeaveRequestModel {
  String? id;
  String? type;
  DateTime? startDate;
  DateTime? endDate;
  String? reason;
  String? attachment;
  String? status;
  String? approvedById;
  DateTime? approvedAt;
  String? rejectReason;
  String? employeeId;
  DateTime? createdAt;
  DateTime? updatedAt;

  LeaveRequestModel({
    this.id,
    this.type,
    this.startDate,
    this.endDate,
    this.reason,
    this.attachment,
    this.status,
    this.approvedById,
    this.approvedAt,
    this.rejectReason,
    this.employeeId,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) => LeaveRequestModel(
    id: json["id"],
    type: json["type"],
    startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
    endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
    reason: json["reason"],
    attachment: json["attachment"],
    status: json["status"],
    approvedById: json["approvedById"],
    approvedAt: json["approvedAt"] == null ? null : DateTime.parse(json["approvedAt"]),
    rejectReason: json["rejectReason"],
    employeeId: json["employeeId"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "startDate": startDate?.toIso8601String(),
    "endDate": endDate?.toIso8601String(),
    "reason": reason,
    "attachment": attachment,
    "status": status,
    "approvedById": approvedById,
    "approvedAt": approvedAt?.toIso8601String(),
    "rejectReason": rejectReason,
    "employeeId": employeeId,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
