import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_models.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  AuthState({this.isLoading = false, this.error});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState());

  Future<bool> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      await _repository.login(LoginRequest(email: email, password: password));
      state = AuthState(isLoading: false);
      return true;
    } on DioException catch (e) {
      String msg = 'Error de conexión';
      if (e.response?.statusCode == 401) {
        msg = 'Correo o contraseña incorrectos.';
      } else if (e.response?.data != null && e.response?.data is Map) {
        final detail = e.response?.data['detail'];
        if (detail is String) {
          msg = detail;
        } else if (detail is List && detail.isNotEmpty) {
          msg = detail[0]['msg'] ?? 'Error de validación';
        } else {
          msg = e.message ?? 'Ocurrió un error inesperado';
        }
      }
      state = AuthState(isLoading: false, error: msg);
      return false;
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
