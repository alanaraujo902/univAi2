import 'package:hive/hive.dart';

part 'subject.g.dart';

@HiveType(typeId: 1)
class Subject extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String color;

  @HiveField(4)
  final String? parentId;

  @HiveField(5)
  final String userId;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final int summariesCount;

  @HiveField(9)
  final List<Subject>? children;

  @HiveField(10)
  final String? icon; // NOVO CAMPO

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    this.parentId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.summariesCount = 0,
    this.children,
    this.icon, // ADICIONADO NO CONSTRUTOR
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      color: json['color'] as String,
      parentId: json['parent_id'] as String?,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      summariesCount: json['summaries_count'] as int? ?? 0,
      icon: json['icon'] as String?, // NOVO CAMPO
      children: json['children'] != null
          ? (json['children'] as List)
          .map((child) => Subject.fromJson(child))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'parent_id': parentId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'summaries_count': summariesCount,
      'icon': icon, // NOVO CAMPO
      'children': children?.map((child) => child.toJson()).toList(),
    };
  }

  Subject copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? parentId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? summariesCount,
    List<Subject>? children,
    String? icon, // NOVO PARÂMETRO
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      summariesCount: summariesCount ?? this.summariesCount,
      children: children ?? this.children,
      icon: icon ?? this.icon, // NOVO CAMPO
    );
  }

  bool get hasChildren => children != null && children!.isNotEmpty;

  bool get isRoot => parentId == null;

  @override
  String toString() {
    return 'Subject(id: $id, name: $name, summariesCount: $summariesCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subject && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
