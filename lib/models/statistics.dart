class Statistics {
  final PeriodStats periodStats;
  final TodayStats todayStats;
  final int streakDays;
  final int pendingReviews;
  final List<SubjectStats> subjectStats;
  final Map<int, int> difficultyDistribution;

  Statistics({
    required this.periodStats,
    required this.todayStats,
    required this.streakDays,
    required this.pendingReviews,
    required this.subjectStats,
    required this.difficultyDistribution,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      periodStats: PeriodStats.fromJson(json['period_stats'] as Map<String, dynamic>),
      todayStats: TodayStats.fromJson(json['today_stats'] as Map<String, dynamic>),
      streakDays: json['streak_days'] as int,
      pendingReviews: json['pending_reviews'] as int,
      subjectStats: (json['subject_stats'] as List?)
          ?.map((item) => SubjectStats.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      difficultyDistribution: Map<int, int>.from(
        json['difficulty_distribution'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period_stats': periodStats.toJson(),
      'today_stats': todayStats.toJson(),
      'streak_days': streakDays,
      'pending_reviews': pendingReviews,
      'subject_stats': subjectStats.map((item) => item.toJson()).toList(),
      'difficulty_distribution': difficultyDistribution,
    };
  }
}

class PeriodStats {
  final int totalSummaries;
  final int totalReviews;
  final int totalStudyTimeMinutes;
  final int subjectsCount;

  PeriodStats({
    required this.totalSummaries,
    required this.totalReviews,
    required this.totalStudyTimeMinutes,
    required this.subjectsCount,
  });

  factory PeriodStats.fromJson(Map<String, dynamic> json) {
    return PeriodStats(
      totalSummaries: json['total_summaries'] as int,
      totalReviews: json['total_reviews'] as int,
      totalStudyTimeMinutes: json['total_study_time_minutes'] as int,
      subjectsCount: json['subjects_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_summaries': totalSummaries,
      'total_reviews': totalReviews,
      'total_study_time_minutes': totalStudyTimeMinutes,
      'subjects_count': subjectsCount,
    };
  }

  String get studyTimeText {
    if (totalStudyTimeMinutes < 60) {
      return '${totalStudyTimeMinutes}min';
    } else {
      final hours = (totalStudyTimeMinutes / 60).floor();
      final minutes = totalStudyTimeMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
  }
}

class TodayStats {
  final int summariesCreated;
  final int summariesReviewed;
  final int studyTimeMinutes;

  TodayStats({
    required this.summariesCreated,
    required this.summariesReviewed,
    required this.studyTimeMinutes,
  });

  factory TodayStats.fromJson(Map<String, dynamic> json) {
    return TodayStats(
      summariesCreated: json['summaries_created'] as int,
      summariesReviewed: json['summaries_reviewed'] as int,
      studyTimeMinutes: json['study_time_minutes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summaries_created': summariesCreated,
      'summaries_reviewed': summariesReviewed,
      'study_time_minutes': studyTimeMinutes,
    };
  }

  String get studyTimeText {
    if (studyTimeMinutes < 60) {
      return '${studyTimeMinutes}min';
    } else {
      final hours = (studyTimeMinutes / 60).floor();
      final minutes = studyTimeMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
  }
}

class SubjectStats {
  final String subjectId;
  final String subjectName;
  final String subjectColor;
  final int summariesCount;
  final int reviewsCount;
  final double averageDifficulty;
  final double retentionRate;

  SubjectStats({
    required this.subjectId,
    required this.subjectName,
    required this.subjectColor,
    required this.summariesCount,
    required this.reviewsCount,
    required this.averageDifficulty,
    required this.retentionRate,
  });

  factory SubjectStats.fromJson(Map<String, dynamic> json) {
    return SubjectStats(
      subjectId: json['subject_id'] as String,
      subjectName: json['subject_name'] as String,
      subjectColor: json['subject_color'] as String,
      summariesCount: json['summaries_count'] as int,
      reviewsCount: json['reviews_count'] as int,
      averageDifficulty: (json['average_difficulty'] as num).toDouble(),
      retentionRate: (json['retention_rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'subject_name': subjectName,
      'subject_color': subjectColor,
      'summaries_count': summariesCount,
      'reviews_count': reviewsCount,
      'average_difficulty': averageDifficulty,
      'retention_rate': retentionRate,
    };
  }

  String get retentionRateText => '${(retentionRate * 100).toStringAsFixed(1)}%';
}

