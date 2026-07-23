import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/lesson_completion_local_datasource.dart';
import '../../../domain/entities/lesson_completion.dart';
import '../../../domain/entities/user_statistics.dart';
import '../../../domain/repositories/course_repository.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final LessonCompletionLocalDataSource completionDataSource;
  final CourseRepository courseRepository;

  StatisticsTimeFilter _currentFilter = StatisticsTimeFilter.allTime;
  String? _selectedCourseId;

  StatisticsBloc({
    required this.completionDataSource,
    required this.courseRepository,
  }) : super(const StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
    on<ChangeTimeFilter>(_onChangeTimeFilter);
    on<ChangeCourseFilter>(_onChangeCourseFilter);
    on<RefreshStatistics>(_onRefreshStatistics);
  }

  Future<void> _onLoadStatistics(
    LoadStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    try {
      _currentFilter = event.filter;
      _selectedCourseId = event.courseId;

      final statistics = await _calculateStatistics();
      emit(StatisticsLoaded(
        statistics: statistics,
        currentFilter: _currentFilter,
        selectedCourseId: _selectedCourseId,
      ));
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }

  Future<void> _onChangeTimeFilter(
    ChangeTimeFilter event,
    Emitter<StatisticsState> emit,
  ) async {
    _currentFilter = event.filter;
    add(LoadStatistics(filter: _currentFilter, courseId: _selectedCourseId));
  }

  Future<void> _onChangeCourseFilter(
    ChangeCourseFilter event,
    Emitter<StatisticsState> emit,
  ) async {
    _selectedCourseId = event.courseId;
    add(LoadStatistics(filter: _currentFilter, courseId: _selectedCourseId));
  }

  Future<void> _onRefreshStatistics(
    RefreshStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    add(LoadStatistics(filter: _currentFilter, courseId: _selectedCourseId));
  }

  Future<UserStatistics> _calculateStatistics() async {
    // Get ALL completions from local storage
    final allCompletionModels = await completionDataSource.getAllCompletions();
    final allCompletions = allCompletionModels.map((m) => m.toEntity()).toList();

    // Apply time filter for display metrics
    final filterStartDate = _currentFilter.startDate;
    List<LessonCompletion> filteredCompletions = allCompletions;
    if (filterStartDate != null) {
      filteredCompletions = allCompletions
          .where((c) => c.completedAt.isAfter(filterStartDate) ||
                        c.completedAt.isAtSameMomentAs(filterStartDate))
          .toList();
    }

    // Calculate metrics from filtered completions
    int videoCompletions = 0;
    int audioCompletions = 0;
    int textCompletions = 0;
    int quizCompletions = 0;
    int flashcardCompletions = 0;
    int totalTimeSpent = 0;
    int totalVideoTime = 0;
    int totalAudioTime = 0;
    int totalTextTime = 0;
    int totalQuizTime = 0;
    int totalFlashcardTime = 0;
    List<int> quizScores = [];
    int quizBestScore = 0;
    List<int> flashcardScores = [];
    int flashcardBestScore = 0;

    for (final completion in filteredCompletions) {
      final duration = completion.durationSeconds ?? 0;
      totalTimeSpent += duration;

      switch (completion.lessonType) {
        case 'video':
          videoCompletions++;
          totalVideoTime += duration;
          break;
        case 'audio':
          audioCompletions++;
          totalAudioTime += duration;
          break;
        case 'text':
          textCompletions++;
          totalTextTime += duration;
          break;
        case 'quiz':
          quizCompletions++;
          totalQuizTime += duration;
          if (completion.scorePercentage != null) {
            quizScores.add(completion.scorePercentage!);
            if (completion.scorePercentage! > quizBestScore) {
              quizBestScore = completion.scorePercentage!;
            }
          }
          break;
        case 'flashcard':
          flashcardCompletions++;
          totalFlashcardTime += duration;
          if (completion.scorePercentage != null) {
            flashcardScores.add(completion.scorePercentage!);
            if (completion.scorePercentage! > flashcardBestScore) {
              flashcardBestScore = completion.scorePercentage!;
            }
          }
          break;
      }
    }

    // Calculate average scores
    double quizAverageScore = quizScores.isNotEmpty
        ? quizScores.reduce((a, b) => a + b) / quizScores.length
        : 0.0;
    double flashcardAverageScore = flashcardScores.isNotEmpty
        ? flashcardScores.reduce((a, b) => a + b) / flashcardScores.length
        : 0.0;

    // Weekly activity chart (always uses all completions)
    final weeklyActivity = _calculateWeeklyActivity(allCompletions);

    // Course progress (always uses all completions)
    final courseProgressResult = await _calculateCourseProgress(allCompletions);

    // Recent completions
    final recentCompletions = _getRecentCompletions(allCompletions, 5);

    // STREAK - always uses ALL completions, not filtered
    final streakData = _calculateStreak(allCompletions);

    // Learning pace
    final paceData = _calculateLearningPace(allCompletions, weeklyActivity);

    return UserStatistics(
      totalCompletions: filteredCompletions.length,
      videoCompletions: videoCompletions,
      audioCompletions: audioCompletions,
      textCompletions: textCompletions,
      quizCompletions: quizCompletions,
      flashcardCompletions: flashcardCompletions,
      totalTimeSpentSeconds: totalTimeSpent,
      quizAverageScore: quizAverageScore,
      quizBestScore: quizBestScore,
      flashcardAverageScore: flashcardAverageScore,
      flashcardBestScore: flashcardBestScore,
      courseProgressList: courseProgressResult.courseProgressList,
      totalCourses: courseProgressResult.totalCourses,
      completedCourses: courseProgressResult.completedCourses,
      weeklyActivity: weeklyActivity,
      recentCompletions: recentCompletions,
      filteredCompletions: filteredCompletions.length,
      filteredTimeSpentSeconds: totalTimeSpent,
      totalLessonsAvailable: courseProgressResult.totalLessonsAvailable,
      // Streak data
      currentStreak: streakData.currentStreak,
      longestStreak: streakData.longestStreak,
      lastActivityDate: streakData.lastActivityDate,
      streakAtRisk: streakData.streakAtRisk,
      // Pace data
      averageLessonsPerDay: paceData.averageLessonsPerDay,
      weeklyAverageLessonsPerDay: paceData.weeklyAverageLessonsPerDay,
      daysSinceFirstLesson: paceData.daysSinceFirstLesson,
      paceTrend: paceData.paceTrend,
      // Time per lesson type (total time, not average)
      avgTimePerVideo: totalVideoTime,
      avgTimePerAudio: totalAudioTime,
      avgTimePerText: totalTextTime,
      avgTimePerQuiz: totalQuizTime,
      avgTimePerFlashcard: totalFlashcardTime,
    );
  }

  /// Calculate streak from ALL completions
  _StreakData _calculateStreak(List<LessonCompletion> completions) {
    if (completions.isEmpty) {
      return _StreakData(
        currentStreak: 0,
        longestStreak: 0,
        lastActivityDate: null,
        streakAtRisk: false,
      );
    }

    // Get unique dates (normalized to midnight)
    final uniqueDates = <DateTime>{};
    for (final completion in completions) {
      uniqueDates.add(DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      ));
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Sort dates descending to get most recent
    final sortedDates = uniqueDates.toList()..sort((a, b) => b.compareTo(a));
    final lastActivityDate = sortedDates.first;

    // Calculate current streak
    int currentStreak = 0;

    // Check if last activity was today or yesterday
    if (lastActivityDate == today || lastActivityDate == yesterday) {
      // Count consecutive days backwards from the last activity date
      DateTime checkDate = lastActivityDate;
      while (uniqueDates.contains(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }
    // If last activity was before yesterday, streak is 0

    // Calculate longest streak ever
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? prevDate;

    final ascendingDates = uniqueDates.toList()..sort();
    for (final date in ascendingDates) {
      if (prevDate == null) {
        tempStreak = 1;
      } else {
        final diff = date.difference(prevDate).inDays;
        if (diff == 1) {
          tempStreak++;
        } else {
          tempStreak = 1;
        }
      }
      if (tempStreak > longestStreak) {
        longestStreak = tempStreak;
      }
      prevDate = date;
    }

    // Streak at risk if last activity was yesterday (not today)
    final streakAtRisk = lastActivityDate == yesterday && currentStreak > 0;

    return _StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastActivityDate: lastActivityDate,
      streakAtRisk: streakAtRisk,
    );
  }

  _PaceData _calculateLearningPace(
    List<LessonCompletion> completions,
    List<DailyActivity> weeklyActivity,
  ) {
    if (completions.isEmpty) {
      return _PaceData(
        averageLessonsPerDay: 0.0,
        weeklyAverageLessonsPerDay: 0.0,
        daysSinceFirstLesson: 0,
        paceTrend: 0,
      );
    }

    final sortedCompletions = List<LessonCompletion>.from(completions)
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    final firstCompletion = sortedCompletions.first.completedAt;
    final daysSinceFirst = DateTime.now().difference(firstCompletion).inDays + 1;
    final averageLessonsPerDay = completions.length / daysSinceFirst;

    final weeklyLessons = weeklyActivity.fold<int>(
      0, (sum, a) => sum + a.lessonsCompleted);
    final weeklyAverageLessonsPerDay = weeklyLessons / 7.0;

    int paceTrend = 0;
    if (daysSinceFirst >= 7 && averageLessonsPerDay > 0) {
      final ratio = weeklyAverageLessonsPerDay / averageLessonsPerDay;
      if (ratio >= 1.2) paceTrend = 1;
      else if (ratio <= 0.8) paceTrend = -1;
    }

    return _PaceData(
      averageLessonsPerDay: averageLessonsPerDay,
      weeklyAverageLessonsPerDay: weeklyAverageLessonsPerDay,
      daysSinceFirstLesson: daysSinceFirst,
      paceTrend: paceTrend,
    );
  }

  List<DailyActivity> _calculateWeeklyActivity(List<LessonCompletion> completions) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    final dailyData = <DateTime, _DailyData>{};
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final normalized = DateTime(date.year, date.month, date.day);
      dailyData[normalized] = _DailyData(0, 0);
    }

    for (final completion in completions) {
      final date = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );
      if (dailyData.containsKey(date)) {
        final existing = dailyData[date]!;
        dailyData[date] = _DailyData(
          existing.lessonsCompleted + 1,
          existing.timeSpentSeconds + (completion.durationSeconds ?? 0),
        );
      }
    }

    return dailyData.entries.map((e) => DailyActivity(
      date: e.key,
      lessonsCompleted: e.value.lessonsCompleted,
      timeSpentSeconds: e.value.timeSpentSeconds,
    )).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<_CourseProgressResult> _calculateCourseProgress(List<LessonCompletion> completions) async {
    final courseProgressList = <CourseProgress>[];
    int totalCourses = 0;
    int completedCourses = 0;
    int totalLessonsAvailable = 0;

    try {
      final result = await courseRepository.getActiveCourses();
      result.fold(
        (failure) {},
        (courses) {
          totalCourses = courses.length;
          for (final course in courses) {
            final totalLessons = course.totalVideos;
            totalLessonsAvailable += totalLessons;
            final courseCompletions = completions.where((c) => c.courseId == course.id).length;
            final actualCompleted = courseCompletions > totalLessons ? totalLessons : courseCompletions;

            courseProgressList.add(CourseProgress(
              courseId: course.id,
              courseName: course.name,
              completedLessons: actualCompleted,
              totalLessons: totalLessons,
            ));

            if (actualCompleted >= totalLessons && totalLessons > 0) {
              completedCourses++;
            }
          }
        },
      );
    } catch (_) {}

    return _CourseProgressResult(
      courseProgressList: courseProgressList,
      totalCourses: totalCourses,
      completedCourses: completedCourses,
      totalLessonsAvailable: totalLessonsAvailable,
    );
  }

  List<RecentCompletion> _getRecentCompletions(List<LessonCompletion> completions, int limit) {
    final sorted = List<LessonCompletion>.from(completions)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return sorted.take(limit).map((c) => RecentCompletion(
      lessonId: c.lessonId,
      lessonTitle: c.lessonId,
      lessonType: c.lessonType ?? 'video',
      completedAt: c.completedAt,
      scorePercentage: c.scorePercentage,
    )).toList();
  }
}

class _DailyData {
  final int lessonsCompleted;
  final int timeSpentSeconds;
  _DailyData(this.lessonsCompleted, this.timeSpentSeconds);
}

class _CourseProgressResult {
  final List<CourseProgress> courseProgressList;
  final int totalCourses;
  final int completedCourses;
  final int totalLessonsAvailable;

  _CourseProgressResult({
    required this.courseProgressList,
    required this.totalCourses,
    required this.completedCourses,
    required this.totalLessonsAvailable,
  });
}

class _StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final bool streakAtRisk;

  _StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
    required this.streakAtRisk,
  });
}

class _PaceData {
  final double averageLessonsPerDay;
  final double weeklyAverageLessonsPerDay;
  final int daysSinceFirstLesson;
  final int paceTrend;

  _PaceData({
    required this.averageLessonsPerDay,
    required this.weeklyAverageLessonsPerDay,
    required this.daysSinceFirstLesson,
    required this.paceTrend,
  });
}
