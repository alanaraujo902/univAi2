import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String email;
  
  @HiveField(2)
  final String fullName;
  
  @HiveField(3)
  final String? avatarUrl;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final DateTime? lastLoginAt;
  
  @HiveField(6)
  final Map<String, dynamic>? preferences;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Pega o sub-dicionário 'user_metadata' de forma segura.
    final metadata = json['user_metadata'] is Map<String, dynamic>
        ? json['user_metadata'] as Map<String, dynamic>
        : <String, dynamic>{};


    // Função auxiliar para processar as datas de forma segura
    DateTime? _parseDate(String? dateString) {
      if (dateString == null) return null;
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        // Se o parse falhar, retorna null para não quebrar o app
        print('Erro ao processar data: $dateString');
        return null;
      }
    }

    return User(
      id: json['id'] as String? ?? '', // Garante que nunca seja nulo
      email: json['email'] as String? ?? '', // Garante que nunca seja nulo

      // Busca o 'full_name' dentro de 'metadata' de forma segura
      fullName: metadata['full_name'] as String? ?? '',

      // Busca o 'avatar_url' dentro de 'metadata'
      avatarUrl: metadata['avatar_url'] as String?,

      // Usa a função segura para processar as datas
      createdAt: _parseDate(json['created_at'] as String?) ?? DateTime.now(),
      lastLoginAt: _parseDate(json['last_sign_in_at'] as String?),


      // 'preferences' não vem do Supabase por padrão, então tratamos como opcional
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'preferences': preferences,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

