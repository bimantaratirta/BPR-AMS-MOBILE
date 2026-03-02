import 'dart:convert';

import 'package:dio/dio.dart';

ApiResponseModel<T> apiResponseModelFromJson<T>(String str, T Function(dynamic) fromJsonT) =>
    ApiResponseModel.fromJson(json.decode(str), fromJsonT);

String apiResponseModelToJson<T>(ApiResponseModel<T> data, Map<String, dynamic> Function(T) toJsonT) =>
    json.encode(data.toJson(toJsonT));

class ApiResponseModel<T> {
  int? code;
  String? status;
  String? message;
  dynamic pagination;
  T? data;
  dynamic errors;
  dynamic error;
  Response<dynamic>? dataraw;

  ApiResponseModel({
    this.code,
    this.status,
    this.message,
    this.pagination,
    this.data,
    this.errors,
    this.error,
    this.dataraw,
  });

  factory ApiResponseModel.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    final rawData = json["data"];

    T? parsedData;
    if (rawData != null) {
      try {
        parsedData = fromJsonT(rawData);
      } catch (e) {
        parsedData = null;
      }
    }

    return ApiResponseModel<T>(
      code: json["code"],
      status: json["status"],
      message: json["message"],
      pagination: json["pagination"],
      data: parsedData,
      errors: json["errors"],
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    final serializedData = data != null ? toJsonT(data!) : null;

    return {
      "code": code,
      "status": status,
      "message": message,
      "pagination": pagination,
      "data": serializedData,
      "errors": errors,
      "error": error,
    };
  }
}
