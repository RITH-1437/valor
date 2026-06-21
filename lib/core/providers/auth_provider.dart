import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_user.dart';
import '../repositories/auth_repository.dart';
import '../storage/secure_storage_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  AuthState({this.status = AuthStatus.loading, this.user, this.error});

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error, bool clearError = false}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final AuthRepository _repo = AuthRepository();

  @override
  AuthState build() {
    _init();
    return AuthState();
  }

  Future<void> _init() async {
    final hasToken = await SecureStorageService.hasToken();
    if (!hasToken) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await _repo.profile();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await SecureStorageService.logout();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await _repo.login(email, password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: _extractError(e));
    }
  }

  Future<void> register({required String name, required String email, required String password, String? phone}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await _repo.register(name: name, email: email, password: password, phone: phone);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: _extractError(e));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  String _extractError(dynamic e) {
    if (e is DioException) {
      if (e.response?.data is Map) {
        final data = e.response!.data;
        if (data['message'] != null) return data['message'];
        if (data['errors'] != null) {
          final errors = data['errors'] as Map;
          return errors.values.first.toString().replaceAll(RegExp(r'[\[\]]'), '');
        }
      }
      return e.message ?? 'Network error';
    }
    return e.toString();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
