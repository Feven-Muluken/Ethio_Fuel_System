import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../env/app_config.dart';

class ApiClient {
  ApiClient({String? baseUrl})
  : _dio = Dio(BaseOptions(baseUrl: baseUrl ?? AppConfig.apiBaseUrl));

  final Dio _dio;

  void setAccessToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAccessToken() {
    _dio.options.headers.remove('Authorization');
  }

  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? query}) {
    return _dio.get(path, queryParameters: query);
  }

  factory ApiClient.defaultClient() {
    return ApiClient(baseUrl: AppConfig.apiBaseUrl);
  }

  Future<Response<dynamic>> post(String path, {Map<String, dynamic>? body}) {
    return _dio.post(path, data: body);
  }

  Future<Response<dynamic>> login({
    required String username,
    required String password,
  }) {
    return post(
      ApiEndpoints.login,
      body: {"username": username, "password": password},
    );
  }

  Future<Response<dynamic>> register({
    required String username,
    required String nationalId,
    required String phoneNumber,
    required String password,
    required bool isStationOperator,
    required bool isRegulator,
  }) {
    return post(
      ApiEndpoints.register,
      body: {
        "username": username,
        "national_id": nationalId,
        "phone_number": phoneNumber,
        "password": password,
        "is_station_operator": isStationOperator,
        "is_regulator": isRegulator,
      },
    );
  }

  Future<Response<dynamic>> fetchMe() {
    return get(ApiEndpoints.me);
  }
}

