import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../router/api_routes.dart';
import 'api_exception.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient(this._tokens) : _dio = Dio() {
    _dio.options
      ..baseUrl = AppConfig.baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15)
      ..headers = {
        'Accept': 'application/json',
      };
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.data is FormData) {
            options.headers.remove(Headers.contentTypeHeader);
            options.contentType = null;
          }
          final skipAuth = options.uri.path.contains(ApiRoutes.login);
          final token = _tokens.token;
          if (!skipAuth && token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _tokens.clear();
          }
          handler.next(error);
        },
      ),
    );
  }

  final TokenStorage _tokens;
  final Dio _dio;

  Dio get raw => _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _send(() => _dio.get<dynamic>(
          path,
          queryParameters: queryParameters,
          options: Options(headers: headers),
        ));
  }

  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _send(() => _dio.post<dynamic>(
          path,
          data: data,
          queryParameters: queryParameters,
        ));
  }

  Future<dynamic> put(String path, {Object? data}) async {
    return _send(() => _dio.put<dynamic>(path, data: data));
  }

  Future<dynamic> putForm(String path, FormData data) async {
    return _send(() => _dio.put<dynamic>(path, data: data));
  }

  Future<dynamic> delete(String path) async {
    return _send(() => _dio.delete<dynamic>(path));
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return unwrap(response.data);
    } on DioException catch (error) {
      throw ApiException(_messageFromDio(error));
    }
  }

  static dynamic unwrap(dynamic data) {
    if (data is! Map) return data;
    if (!data.containsKey('isSuccess')) return data;
    if (data['isSuccess'] != true) {
      final message = data['errorMessage'] as String?;
      throw ApiException(
        (message == null || message.isEmpty) ? 'Request failed' : message,
      );
    }
    return data['value'];
  }

  static String _messageFromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['errorMessage'] is String) {
      final message = data['errorMessage'] as String;
      if (message.isNotEmpty) return message;
    }
    if (error.type == DioExceptionType.connectionError) {
    print ('error.message: ${error.message}');
      return 'Could not reach the server 1 ';
    }

      else if  (error.type == DioExceptionType.connectionTimeout) {
      print ('error.message: ${error.message}');
      return 'Could not reach the server 2';
    }
    if (error.response?.statusCode == 400 ||
        error.response?.statusCode == 401) {
      return 'invalidCredentials';
    }
    return error.message ?? 'Request failed';
  }
}
