import 'package:hive/hive.dart';

part 'review.g.dart';

@HiveType(typeId: 3)
class Review extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String summaryId;
  
  @HiveField(2)
  final String userId;
  
  @HiveField(3)
  final DateTime reviewedAt;
  
  @HiveField(4)
  final int quality; // 1-5 (SM-2 algorithm)
  
  @HiveField(5)
  final int interval; // dias até próxima revisão
  
  @HiveField(6)
  final double easeFactor;
  
  @HiveField(7)
  final int repetition;
  
  @HiveField(8)
  final DateTime? nextReviewAt;
  
  @HiveField(9)
  final int timeSpentSeconds;

  Review({
    required this.id,
    required this.summaryId,
    required this.userId,
    required this.reviewedAt,
    required this.quality,
    required this.interval,
    required this.easeFactor,
    required this.repetition,
    this.nextReviewAt,
    this.timeSpentSeconds = 0,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      summaryId: json['summary_id'] as String,
      userId: json['user_id'] as String,
      reviewedAt: DateTime.parse(json['reviewed_at'] as String),
      quality: json['quality'] as int,
      interval: json['interval'] as int,
      easeFactor: (json['ease_factor'] as num).toDouble(),
      repetition: json['repetition'] as int,
      nextReviewAt: json['next_review_at'] != null
          ? DateTime.parse(json['next_review_at'] as String)
          : null,
      timeSpentSeconds: json['time_spent_seconds'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'summary_id': summaryId,
      'user_id': userId,
      'reviewed_at': reviewedAt.toIso8601String(),
      'quality': quality,
      'interval': interval,
      'ease_factor': easeFactor,
      'repetition': repetition,
      'next_review_at': nextReviewAt?.toIso8601String(),
      'time_spent_seconds': timeSpentSeconds,
    };
  }

  Review copyWith({
    String? id,
    String? summaryId,
    String? userId,
    DateTime? reviewedAt,
    int? quality,
    int? interval,
    double? easeFactor,
    int? repetition,
    DateTime? nextReviewAt,
    int? timeSpentSeconds,
  }) {
    return Review(
      id: id ?? this.id,
      summaryId: summaryId ?? this.summaryId,
      userId: userId ?? this.userId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      quality: quality ?? this.quality,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      repetition: repetition ?? this.repetition,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
    );
  }

  String get qualityText {
    switch (quality) {
      case 1: return 'Muito Difícil';
      case 2: return 'Difícil';
      case 3: return 'Médio';
      case 4: return 'Fácil';
      case 5: return 'Muito Fácil';
      default: return 'Médio';
    }
  }

  String get timeSpentText {
    if (timeSpentSeconds < 60) {
      return '${timeSpentSeconds}s';
    } else if (timeSpentSeconds < 3600) {
      final minutes = (timeSpentSeconds / 60).round();
      return '${minutes}min';
    } else {
      final hours = (timeSpentSeconds / 3600).round();
      return '${hours}h';
    }
  }

  @override
  String toString() {
    return 'Review(id: $id, summaryId: $summaryId, quality: $quality)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

