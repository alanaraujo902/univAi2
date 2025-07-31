import 'dart:convert';
import 'package:study_app/constants/app_constants.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/services/api_service.dart';
import 'package:study_app/services/storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  // Login
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _api.post(
        '${AppConstants.authEndpoint}/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Bloco de try-catch específico para o processamento dos dados
        try {
          final data = response.data as Map<String, dynamic>;
          final token = data['access_token'] as String;
          final userData = data['user'] as Map<String, dynamic>;

          final user = User.fromJson(userData);

          await _storage.saveToken(token);
          await _storage.saveUser(user);

          return AuthResult.success(user: user, token: token);
        } catch (e, stackTrace) {
          // Se o processamento falhar, o erro exato será impresso aqui
          print('--- ERRO AO PROCESSAR A RESPOSTA DO LOGIN ---');
          print('Erro: $e');
          print('StackTrace: $stackTrace');
          print('Dados recebidos que causaram o erro: ${response.data}');
          print('-------------------------------------------');
          return AuthResult.failure(message: 'Erro ao processar os dados do usuário.');
        }
      } else {
        return AuthResult.failure(
          message: AppConstants.errorMessages['invalid_credentials']!,
        );
      }
    } on ApiException catch (e) {
      return AuthResult.failure(message: e.message);
    } catch (e) {
      return AuthResult.failure(
        message: AppConstants.errorMessages['server_error']!,
      );
    }
  }

  // Registro
  Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _api.post(
        '${AppConstants.authEndpoint}/register',
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>;
        
        final user = User.fromJson(userData);
        
        return AuthResult.success(user: user);
      } else {
        return AuthResult.failure(
          message: 'Erro ao criar conta',
        );
      }
    } on ApiException catch (e) {
      return AuthResult.failure(message: e.message);
    } catch (e) {
      return AuthResult.failure(
        message: AppConstants.errorMessages['server_error']!,
      );
    }
  }

  // Verificar se está logado
  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null;
  }

  // Obter usuário atual
  Future<User?> getCurrentUser() async {
    try {
      final user = await _storage.getUser();
      if (user != null) {
        return user;
      }

      // Se não tem usuário salvo, buscar do servidor
      final response = await _api.get('${AppConstants.authEndpoint}/profile');
      
      if (response.statusCode == 200) {
        final userData = response.data['user'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        await _storage.saveUser(user);
        return user;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Atualizar perfil
  Future<AuthResult> updateProfile({
    String? fullName,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      if (preferences != null) data['preferences'] = preferences;

      final response = await _api.put(
        '${AppConstants.authEndpoint}/profile',
        data: data,
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        await _storage.saveUser(user);
        
        return AuthResult.success(user: user);
      } else {
        return AuthResult.failure(message: 'Erro ao atualizar perfil');
      }
    } on ApiException catch (e) {
      return AuthResult.failure(message: e.message);
    } catch (e) {
      return AuthResult.failure(
        message: AppConstants.errorMessages['server_error']!,
      );
    }
  }

  // Alterar senha
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _api.put(
        '${AppConstants.authEndpoint}/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return AuthResult.success();
      } else {
        return AuthResult.failure(message: 'Erro ao alterar senha');
      }
    } on ApiException catch (e) {
      return AuthResult.failure(message: e.message);
    } catch (e) {
      return AuthResult.failure(
        message: AppConstants.errorMessages['server_error']!,
      );
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _api.post('${AppConstants.authEndpoint}/logout');
    } catch (e) {
      // Ignorar erros de logout no servidor
    } finally {
      // Sempre limpar dados locais
      await _storage.clearToken();
      await _storage.clearUser();
    }
  }

  // Validações
  static bool isValidEmail(String email) {
    return RegExp(AppConstants.emailPattern).hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 8;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return AppConstants.errorMessages['required_field'];
    }
    if (!isValidEmail(email)) {
      return AppConstants.errorMessages['invalid_email'];
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return AppConstants.errorMessages['required_field'];
    }
    if (!isValidPassword(password)) {
      return AppConstants.errorMessages['weak_password'];
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return AppConstants.errorMessages['required_field'];
    }
    if (name.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }
}

// Resultado de operações de autenticação
class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final String? token;

  AuthResult._({
    required this.success,
    this.message,
    this.user,
    this.token,
  });

  factory AuthResult.success({User? user, String? token}) {
    return AuthResult._(
      success: true,
      user: user,
      token: token,
    );
  }

  factory AuthResult.failure({required String message}) {
    return AuthResult._(
      success: false,
      message: message,
    );
  }
}

