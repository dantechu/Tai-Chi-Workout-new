import 'package:equatable/equatable.dart';

/// Entity representing user statistics and analytics.
class UserStatistics extends Equatable {
  /// Total number of lessons completed
  final int totalCompletions;

  /// Completions by lesson type
  final int videoCompletions;
  final int audioCompletions;
  final int textCompletions;
  final int quizCompletions;
  final int flashcardCompletions;

  /// Total estimated time spent (in seconds)
  final int totalTimeSpentSeconds;

  /// Quiz scores
  final double quizAverageScore;
  final int quizBestScore;

  /// Flashcard scores
  final double flashcardAverageScore;
  final int flashcardBestScore;

  /// Course progress data
  final List<CourseProgress> courseProgressList;

  /// Total courses
  final int totalCourses;

  /// Completed courses (100% progress)
  final int completedCourses;

  /// Weekly activity data (last 7 days)
  final List<DailyActivity> weeklyActivity;

  /// Recent completions (last 5)
  final List<RecentCompletion> recentCompletions;

  /// Completions for the selected time filter
  final int filteredCompletions;

  /// Time spent for the selected time filter (in seconds)
  final int filteredTimeSpentSeconds;

  /// Total lessons available across all courses
  final int totalLessonsAvailable;

  const UserStatistics({
    this.totalCompletions = 0,
    this.videoCompletions = 0,
    this.audioCompletions = 0,
    this.textCompletions = 0,
    this.quizCompletions = 0,
    this.flashcardCompletions = 0,
    this.totalTimeSpentSeconds = 0,
    this.quizAverageScore = 0.0,
    this.quizBestScore = 0,
    this.flashcardAverageScore = 0.0,
    this.flashcardBestScore = 0,
    this.courseProgressList = const [],
    this.totalCourses = 0,
    this.completedCourses = 0,
    this.weeklyActivity = const [],
    this.recentCompletions = const [],
    this.filteredCompletions = 0,
    this.filteredTimeSpentSeconds = 0,
    this.totalLessonsAvailable = 0,
  });

  /// Get formatted time spent string (e.g., "2h 30m")
  String get formattedTotalTime => _formatDuration(totalTimeSpentSeconds);

  /// Get formatted filtered time spent string
  String get formattedFilteredTime => _formatDuration(filteredTimeSpentSeconds);

  /// Overall completion percentage
  double get overallProgress {
    if (totalLessonsAvailable == 0) return 0.0;
    return (totalCompletions / totalLessonsAvailable * 100).clamp(0.0, 100.0);
  }

  /// Lessons remaining
  int get lessonsRemaining => (totalLessonsAvailable - totalCompletions).clamp(0, totalLessonsAvailable);

  /// Courses remaining
  int get coursesRemaining => totalCourses - completedCourses;

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    }
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  List<Object?> get props => [
        totalCompletions,
        videoCompletions,
        audioCompletions,
        textCompletions,
        quizCompletions,
        flashcardCompletions,
        totalTimeSpentSeconds,
        quizAverageScore,
        quizBestScore,
        flashcardAverageScore,
        flashcardBestScore,
        courseProgressList,
        totalCourses,
        completedCourses,
        weeklyActivity,
        recentCompletions,
        filteredCompletions,
        filteredTimeSpentSeconds,
        totalLessonsAvailable,
      ];
}

/// Course progress data
class CourseProgress extends Equatable {
  final String courseId;
  final String courseName;
  final int completedLessons;
  final int totalLessons;

  const CourseProgress({
    required this.courseId,
    required this.courseName,
    required this.completedLessons,
    required this.totalLessons,
  });

  double get progressPercentage {
    if (totalLessons == 0) return 0.0;
    return (completedLessons / totalLessons * 100).clamp(0.0, 100.0);
  }

  bool get isCompleted => completedLessons >= totalLessons && totalLessons > 0;

  @override
  List<Object?> get props => [courseId, courseName, completedLessons, totalLessons];
}

/// Daily activity data for charts
class DailyActivity extends Equatable {
  final DateTime date;
  final int lessonsCompleted;
  final int timeSpentSeconds;

  const DailyActivity({
    required this.date,
    required this.lessonsCompleted,
    required this.timeSpentSeconds,
  });

  String get dayLabel {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  @override
  List<Object?> get props => [date, lessonsCompleted, timeSpentSeconds];
}

/// Recent completion data
class RecentCompletion extends Equatable {
  final String lessonId;
  final String lessonTitle;
  final String lessonType;
  final DateTime completedAt;
  final int? scorePercentage;

  const RecentCompletion({
    required this.lessonId,
    required this.lessonTitle,
    required this.lessonType,
    required this.completedAt,
    this.scorePercentage,
  });

  @override
  List<Object?> get props => [lessonId, lessonTitle, lessonType, completedAt, scorePercentage];
}

/// Time filter options for statistics
enum StatisticsTimeFilter {
  today,
  thisWeek,
  thisMonth,
  allTime,
}

extension StatisticsTimeFilterExtension on StatisticsTimeFilter {
  DateTime? get startDate {
    final now = DateTime.now();
    switch (this) {
      case StatisticsTimeFilter.today:
        return DateTime(now.year, now.month, now.day);
      case StatisticsTimeFilter.thisWeek:
        return DateTime(now.year, now.month, now.day - now.weekday + 1);
      case StatisticsTimeFilter.thisMonth:
        return DateTime(now.year, now.month, 1);
      case StatisticsTimeFilter.allTime:
        return null;
    }
  }
}
