import 'dart:convert';

import 'package:bpr_ams/app/common/constant/app_constants.dart';
import 'package:bpr_ams/app/common/utils/helper.dart';
import 'package:bpr_ams/app/data/storage/storage_client.dart';
import 'package:bpr_ams/app/routes/app_pages.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

class DioInterceptor extends Interceptor {
  final Dio dio;

  DioInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = StorageClient.getAccessToken();

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    if (kDebugMode) {
      print('REQUEST[${options.method}] => PATH: ${options.path}');
      print('Headers: ${options.headers}');
      print('Query Parameters: ${options.queryParameters}');
      print('Data: ${options.data}');
    }

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');

      if (response.data is List<int>) {
        try {
          final dataString = utf8.decode(response.data as List<int>);
          print('Response Data (decoded as text): $dataString');
        } catch (e) {
          print('Response Data: Received ${response.data.length} bytes (binary file).');
        }
      } else {
        print('Response Data: ${response.data}');
      }
    }

    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');

      if (err.response?.data is List<int>) {
        final dataString = utf8.decode(err.response?.data as List<int>);
        print('Error Data (decoded): $dataString');
      } else {
        print('Error Data: ${err.response?.data ?? err.response ?? err}');
      }
    }

    await _handleJWTError(err, handler);
  }

  // Handle JWT errors
  Future<void> _handleJWTError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Jika yang gagal adalah request refresh token itu sendiri, jangan loop
      final path = err.requestOptions.path;
      if (path.contains('refresh-token')) {
        await StorageClient.clearSession();
        await _redirectToLogin();
        return handler.reject(err);
      }

      try {
        final refreshToken = StorageClient.getRefreshToken();
        if (refreshToken != null) {
          await _refreshJWTToken(refreshToken);

          // Retry request asal dengan access token baru
          final response = await _retryRequestWithJWT(err.requestOptions);
          return handler.resolve(response);
        } else {
          await _redirectToLogin();
          return handler.reject(err);
        }
      } catch (e) {
        // Refresh token gagal, paksa login ulang
        await StorageClient.clearSession();
        await _redirectToLogin();
        return handler.reject(err);
      }
    } else {
      return super.onError(err, handler);
    }
  }

  // Refresh JWT token menggunakan refresh token
  Future<void> _refreshJWTToken(String refreshToken) async {
    final userType = StorageClient.getUserType();
    final isEmployee = userType == 'EMPLOYEE';
    final endpoint =
        isEmployee
            ? '${AppConstants.baseApiUrl}${AppConstants.refreshTokenEmployeeEndpoint}'
            : '${AppConstants.baseApiUrl}${AppConstants.refreshTokenAdminEndpoint}';

    // Gunakan Dio baru tanpa interceptor agar tidak loop
    final freshDio = Dio();
    final response = await freshDio.post(endpoint, options: Options(headers: {'Authorization': 'Bearer $refreshToken'}));

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'];
      if (data != null && data['access_token'] != null) {
        final newAccessToken = data['access_token'] as String;
        final newRefreshToken = data['refresh_token'] as String? ?? refreshToken;
        await StorageClient.saveToken(newAccessToken, newRefreshToken);

        final payload = Helper().decodeJwt(newAccessToken);
        final exp = payload?['exp'];
        if (exp != null) await StorageClient.saveTokenExpiry((exp as num).toInt());
      }
    } else {
      throw Exception('Refresh token gagal');
    }
  }

  // Method to retry failed request with JWT
  Future<Response<dynamic>> _retryRequestWithJWT(RequestOptions requestOptions) async {
    final accessToken = StorageClient.getAccessToken();

    final options = Options(
      method: requestOptions.method,
      headers: {...requestOptions.headers, 'Authorization': 'Bearer $accessToken'},
    );

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<void> _redirectToLogin() async {
    if (kDebugMode) {
      print('Redirecting to login...');
    }
    // Clear all sessions
    await StorageClient.clearSession();

    // Navigate to login page
    Get.offAllNamed(Routes.AUTH_LOGIN); // Adjust route name as needed
  }
}
