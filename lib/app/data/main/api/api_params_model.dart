import 'package:dio/dio.dart';

class ApiParams<T> {
  final String? baseUrl;
  final String path;
  final T Function(dynamic)? fromJson;
  final Map<String, dynamic>? body;
  final FormData? formData;
  final Map<String, dynamic>? queryParameters;
  final Options? options;

  ApiParams({this.baseUrl, required this.path, this.fromJson, this.queryParameters, this.body, this.formData, this.options});
}
