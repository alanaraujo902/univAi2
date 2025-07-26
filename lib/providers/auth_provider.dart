import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/services/auth_service.dart';
import 'package:study_app/services/storage_service.dart';

// Estado de autenticação
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  AuthState({
    required this.status,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

// Notifier de autenticação
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  AuthNotifier() : super(AuthState(status: AuthStatus.initial)) {
    _checkAuthStatus();
  }

  // Verificar status de autenticação inicial
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final result = await _authService.login(email, password);
      
      if (result.success) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.user,
          error: null,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: result.message,
        );
        throw Exception(result.message);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Registro
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      
      if (result.success) {
        // Após registro bem-sucedido, manter como não autenticado
        // para que o usuário faça login
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: null,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: result.message,
        );
        throw Exception(result.message);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Atualizar perfil
  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final result = await _authService.updateProfile(
        fullName: fullName,
        avatarUrl: avatarUrl,
        preferences: preferences,
      );
      
      if (result.success && result.user != null) {
        state = state.copyWith(
          user: result.user,
          error: null,
        );
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Alterar senha
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final result = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      if (!result.success) {
        throw Exception(result.message);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        error: null,
      );
    } catch (e) {
      // Mesmo com erro, fazer logout local
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        error: null,
      );
    }
  }

  // Limpar erro
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider de autenticação
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

