import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/dio_client.dart';
import '../domain/auth_models.dart';



final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(dio, storage);
});

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<void> login(LoginRequest request) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'username': request.email, // FastAPI OAuth2 espera 'username'
        'password': request.password,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final authData = AuthResponse.fromJson(response.data);
    await _storage.write(key: 'access_token', value: authData.accessToken);
    await _storage.write(key: 'refresh_token', value: authData.refreshToken);
  }

  Future<void> register(RegisterRequest request) async {
    await _dio.post('/auth/register', data: request.toJson());
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }
}
