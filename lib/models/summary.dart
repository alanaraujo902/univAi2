import 'package:hive/hive.dart';
import 'package:study_app/models/subject.dart';

part 'summary.g.dart';

@HiveType(typeId: 2)
class Summary extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String content;
  
  @HiveField(3)
  final String subjectId;
  
  @HiveField(4)
  final String userId;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final DateTime updatedAt;
  
  @HiveField(7)
  final bool isFavorite;
  
  @HiveField(8)
  final int difficultyLevel;
  
  @HiveField(9)
  final List<String> tags;
  
  @HiveField(10)
  final String? imageUrl;
  
  @HiveField(11)
  final String? originalQuery;
  
  @HiveField(12)
  final List<String>? citations;
  
  @HiveField(13)
  final Subject? subject;
  
  @HiveField(14)
  final DateTime? lastReviewedAt;
  
  @HiveField(15)
  final DateTime? nextReviewAt;
  
  @HiveField(16)
  final int reviewCount;
  
  @HiveField(17)
  final double easeFactor;

  Summary({
    required this.id,
    required this.title,
    required this.content,
    required this.subjectId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.difficultyLevel = 3,
    this.tags = const [],
    this.imageUrl,
    this.originalQuery,
    this.citations,
    this.subject,
    this.lastReviewedAt,
    this.nextReviewAt,
    this.reviewCount = 0,
    this.easeFactor = 2.5,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      subjectId: json['subject_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isFavorite: json['is_favorite'] as bool? ?? false,
      difficultyLevel: json['difficulty_level'] as int? ?? 3,
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'] as List)
          : [],
      imageUrl: json['image_url'] as String?,
      originalQuery: json['original_query'] as String?,
      citations: json['citations'] != null
          ? List<String>.from(json['citations'] as List)
          : null,
      subject: json['subject'] != null
          ? Subject.fromJson(json['subject'] as Map<String, dynamic>)
          : null,
      lastReviewedAt: json['last_reviewed_at'] != null
          ? DateTime.parse(json['last_reviewed_at'] as String)
          : null,
      nextReviewAt: json['next_review_at'] != null
          ? DateTime.parse(json['next_review_at'] as String)
          : null,
      reviewCount: json['review_count'] as int? ?? 0,
      easeFactor: (json['ease_factor'] as num?)?.toDouble() ?? 2.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'subject_id': subjectId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_favorite': isFavorite,
      'difficulty_level': difficultyLevel,
      'tags': tags,
      'image_url': imageUrl,
      'original_query': originalQuery,
      'citations': citations,
      'subject': subject?.toJson(),
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
      'next_review_at': nextReviewAt?.toIso8601String(),
      'review_count': reviewCount,
      'ease_factor': easeFactor,
    };
  }

  Summary copyWith({
    String? id,
    String? title,
    String? content,
    String? subjectId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    int? difficultyLevel,
    List<String>? tags,
    String? imageUrl,
    String? originalQuery,
    List<String>? citations,
    Subject? subject,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
    int? reviewCount,
    double? easeFactor,
  }) {
    return Summary(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      subjectId: subjectId ?? this.subjectId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      originalQuery: originalQuery ?? this.originalQuery,
      citations: citations ?? this.citations,
      subject: subject ?? this.subject,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      reviewCount: reviewCount ?? this.reviewCount,
      easeFactor: easeFactor ?? this.easeFactor,
    );
  }

  bool get needsReview {
    if (nextReviewAt == null) return true;
    return DateTime.now().isAfter(nextReviewAt!);
  }

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  
  bool get hasCitations => citations != null && citations!.isNotEmpty;
  
  String get difficultyText {
    switch (difficultyLevel) {
      case 1: return 'Muito Fácil';
      case 2: return 'Fácil';
      case 3: return 'Médio';
      case 4: return 'Difícil';
      case 5: return 'Muito Difícil';
      default: return 'Médio';
    }
  }

  @override
  String toString() {
    return 'Summary(id: $id, title: $title, difficultyLevel: $difficultyLevel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Summary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

