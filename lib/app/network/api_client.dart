import 'dart:convert';

import 'package:bpr_ams/app/common/constant/app_constants.dart';
import 'package:bpr_ams/app/data/main/api/api_params_model.dart';
import 'package:bpr_ams/app/data/main/api/api_response_model.dart';
import 'package:bpr_ams/app/network/dio_interceptor.dart';
import 'package:dio/dio.dart';

enum ResponseStatus { normal, waiting, success, connectionError, serverError, notFound }

class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseApiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  ApiClient() {
    _dio.interceptors.add(DioInterceptor(_dio));
  }

  /// Flatten nested Map/List jadi bracket notation: `filter[month]=2026-02`,
  /// `pagination[page]=1`, `order_by[0][field]=created_at`. Tanpa ini, Dio
  /// JSON-encode nested Map → backend qs parser baca sebagai string, filter
  /// nested kayak `filter.month` jadi undefined di server.
  Map<String, dynamic>? _flattenQuery(Map<String, dynamic>? params) {
    if (params == null) return null;
    final result = <String, dynamic>{};
    void walk(String key, dynamic value) {
      if (value == null) return;
      if (value is Map) {
        value.forEach((k, v) => walk('$key[$k]', v));
      } else if (value is List) {
        for (var i = 0; i < value.length; i++) {
          walk('$key[$i]', value[i]);
        }
      } else {
        result[key] = value;
      }
    }
    params.forEach((k, v) {
      if (v is Map || v is List) {
        walk(k, v);
      } else {
        result[k] = v;
      }
    });
    return result;
  }

  Future<ApiResponseModel<T>> _responseHandler<T>(Response response, ApiParams<T> param) async {
    if (param.options?.responseType == ResponseType.bytes) {
      if (response.data != null && response.data is List<int>) {
        final dataString = utf8.decode(response.data as List<int>);
        final dataJson = jsonDecode(dataString);

        return ApiResponseModel<T>(
          code: response.statusCode,
          status: response.statusMessage ?? 'OK',
          message: 'File downloaded successfully',
          data: dataJson,
          dataraw: response,
        );
      }
    }

    final jsonBody = response.data is String ? json.decode(response.data) : response.data;
    final jsonString = json.encode(jsonBody);

    try {
      final ApiResponseModel<T> result = apiResponseModelFromJson<T>(jsonString, (jsonMap) => param.fromJson!(jsonMap));

      return result;
    } catch (e) {
      return ApiResponseModel<T>(
        code: response.statusCode,
        status: 'error',
        message: 'Gagal memproses data respons dari server.',
        error: e.toString(),
        data: null,
      );
    }
  }

  Future<ApiResponseModel<T>> _errorHandler<T>(DioException e) async {
    final int statusCode = e.response?.statusCode ?? 0;
    String? message = 'Terjadi kesalahan tidak dikenal';
    dynamic apiErrors; // Untuk field 'errors' (jamak) dari API
    dynamic manualError; // Untuk field 'error' (tunggal) manual

    if (e.response != null && e.response?.data != null && e.response!.data is List<int>) {
      final dataString = utf8.decode(e.response?.data as List<int>);
      final dataJson = jsonDecode(dataString);

      if (dataJson is Map<String, dynamic>) {
        message = dataJson['message'] ?? dataJson['status'] ?? 'Terjadi kesalahan server';
        apiErrors = dataJson['errors'] ?? dataJson['error'];
      }
    } else if (e.response != null && e.response!.data != null) {
      dynamic responseData = e.response!.data;

      // Pastikan responseData adalah Map
      if (responseData is String) {
        try {
          responseData = json.decode(responseData);
        } catch (_) {
          // Gagal decode JSON
          message = 'Gagal memproses error response body dari server';
          manualError = 'Invalid JSON in error response';
          responseData = null;
        }
      }

      if (responseData is Map<String, dynamic>) {
        // Coba ambil message dan errors dari body JSON
        message = responseData['message'] ?? responseData['status'] ?? 'Terjadi kesalahan server';
        apiErrors = responseData['errors'] ?? responseData['error']; // Ambil 'errors' atau 'error' dari API
      }
    } else {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          message = 'Koneksi ke server gagal. Periksa koneksi internet Anda.';
          manualError = ResponseStatus.connectionError;
          break;
        case DioExceptionType.badResponse:
          // Status code sudah ditangkap, pesan diambil dari logic di atas.
          if (statusCode >= 500) {
            message = 'Terjadi kesalahan pada server (Status: $statusCode).';
            manualError = ResponseStatus.serverError;
          }
          break;
        default:
          message = 'Terjadi kesalahan tak terduga: ${e.message}';
          manualError = e.type.toString();
      }
    }

    return ApiResponseModel<T>(
      code: statusCode,
      status: 'error',
      message: message,
      errors: apiErrors,
      error: manualError,
      data: null,
    );
  }

  Future<ApiResponseModel<T>> get<T>(ApiParams<T> param) async {
    try {
      _dio.options.baseUrl = param.baseUrl != null ? param.baseUrl! : AppConstants.baseApiUrl;
      final response = await _dio.get(
        param.path,
        data: param.body != null ? json.encode(param.body) : null,
        queryParameters: _flattenQuery(param.queryParameters),
        options: param.options,
      );
      final ApiResponseModel<T> result = await _responseHandler<T>(response, param);
      return result;
    } on DioException catch (e) {
      final ApiResponseModel<T> error = await _errorHandler(e);
      return error;
    }
  }

  Future<ApiResponseModel<T>> post<T>(ApiParams<T> param) async {
    try {
      _dio.options.baseUrl = param.baseUrl != null ? param.baseUrl! : AppConstants.baseApiUrl;

      dynamic requestData;
      if (param.formData != null) {
        requestData = param.formData;
      } else if (param.body != null) {
        requestData = json.encode(param.body);
      }

      final response = await _dio.post(
        param.path,
        data: requestData,
        queryParameters: _flattenQuery(param.queryParameters),
        options: param.options,
      );
      final ApiResponseModel<T> result = await _responseHandler<T>(response, param);
      return result;
    } on DioException catch (e) {
      final ApiResponseModel<T> error = await _errorHandler(e);
      return error;
    }
  }

  Future<ApiResponseModel<T>> patch<T>(ApiParams<T> param) async {
    try {
      _dio.options.baseUrl = param.baseUrl != null ? param.baseUrl! : AppConstants.baseApiUrl;

      dynamic requestData;
      if (param.formData != null) {
        requestData = param.formData;
      } else if (param.body != null) {
        requestData = json.encode(param.body);
      }

      final response = await _dio.patch(
        param.path,
        data: requestData,
        queryParameters: _flattenQuery(param.queryParameters),
        options: param.options,
      );
      final ApiResponseModel<T> result = await _responseHandler<T>(response, param);
      return result;
    } on DioException catch (e) {
      final ApiResponseModel<T> error = await _errorHandler(e);
      return error;
    }
  }

  Future<ApiResponseModel<T>> put<T>(ApiParams<T> param) async {
    try {
      _dio.options.baseUrl = param.baseUrl != null ? param.baseUrl! : AppConstants.baseApiUrl;
      final response = await _dio.put(
        param.path,
        data: param.body != null ? json.encode(param.body) : null,
        queryParameters: _flattenQuery(param.queryParameters),
        options: param.options,
      );
      final ApiResponseModel<T> result = await _responseHandler<T>(response, param);
      return result;
    } on DioException catch (e) {
      final ApiResponseModel<T> error = await _errorHandler(e);
      return error;
    }
  }

  Future<ApiResponseModel<T>> delete<T>(ApiParams<T> param) async {
    try {
      _dio.options.baseUrl = param.baseUrl != null ? param.baseUrl! : AppConstants.baseApiUrl;
      final response = await _dio.delete(
        param.path,
        data: param.body != null ? json.encode(param.body) : null,
        queryParameters: _flattenQuery(param.queryParameters),
        options: param.options,
      );
      final ApiResponseModel<T> result = await _responseHandler<T>(response, param);
      return result;
    } on DioException catch (e) {
      final ApiResponseModel<T> error = await _errorHandler(e);
      return error;
    }
  }

  Future<ApiResponseModel<T>> getRaw<T>(ApiParams<T> param) async {
    try {
      _dio.options.baseUrl = param.baseUrl != null ? param.baseUrl! : AppConstants.baseApiUrl;

      final response = await _dio.get(param.path, queryParameters: _flattenQuery(param.queryParameters), options: param.options);

      if (response.statusCode != 200) {
        return await _responseHandler<T>(response, param);
      }

      return ApiResponseModel<T>(
        code: response.statusCode,
        status: 'OK',
        message: 'Raw data fetched successfully',
        data: null,
        dataraw: response,
      );
    } on DioException catch (e) {
      final ApiResponseModel<T> error = await _errorHandler(e);
      return error;
    }
  }
}

final ApiClient apiClient = ApiClient();
