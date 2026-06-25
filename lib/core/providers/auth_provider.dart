import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../data/mock_repositories.dart';
import '../models/api_user.dart';
import '../network/api_client.dart' show ApiClient, ApiMode;
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

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiClient.apiMode == ApiMode.live ? ApiAuthRepository() : MockAuthRepository();
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _init();
    return AuthState();
  }

  Future<void> _init() async {
    final hasToken = await SecureStorageService.hasToken();
    if (!hasToken) {
      if (ApiClient.apiMode != ApiMode.live) {
        final user = UserModel(id: 1, name: 'James Anderson', email: 'james@valor.com', avatar: null, phone: '+1-555-0123');
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return;
      }
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await ref.read(authRepositoryProvider).profile();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      if (ApiClient.apiMode != ApiMode.live) {
        final user = UserModel(id: 1, name: 'James Anderson', email: 'james@valor.com', avatar: null, phone: '+1-555-0123');
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return;
      }
      await SecureStorageService.logout();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await ref.read(authRepositoryProvider).login(email, password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: _extractError(e));
    }
  }

  Future<void> register({required String name, required String email, required String password, String? phone}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await ref.read(authRepositoryProvider).register(name: name, email: email, password: password, phone: phone);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: _extractError(e));
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> uploadAvatar(XFile file) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await ref.read(authRepositoryProvider).uploadAvatar(file);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.authenticated, error: _extractError(e));
    }
  }

  Future<void> removeAvatar() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await ref.read(authRepositoryProvider).deleteAvatar();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.authenticated, error: _extractError(e));
    }
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
