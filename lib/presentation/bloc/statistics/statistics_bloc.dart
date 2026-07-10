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
    final allCompletionModels = await completionDataSource.getAllCompletions();

    // Convert all completions to entities
    List<LessonCompletion> allCompletions = allCompletionModels
        .map((m) => m.toEntity())
        .toList();

    // Filter by time for display metrics
    final filterStartDate = _currentFilter.startDate;
    List<LessonCompletion> filteredCompletions = allCompletions;
    if (filterStartDate != null) {
      filteredCompletions = allCompletions
          .where((c) => c.completedAt.isAfter(filterStartDate))
          .toList();
    }

    // Calculate metrics from ALL completions (not filtered by course)
    int videoCompletions = 0;
    int audioCompletions = 0;
    int textCompletions = 0;
    int quizCompletions = 0;
    int flashcardCompletions = 0;
    int totalTimeSpent = 0;
    int filteredTimeSpent = 0;

    // Separate scores for quiz and flashcard
    List<int> quizScores = [];
    int quizBestScore = 0;
    List<int> flashcardScores = [];
    int flashcardBestScore = 0;

    // Count by type for all completions
    for (final completion in allCompletions) {
      final duration = completion.durationSeconds ?? 0;
      totalTimeSpent += duration;

      switch (completion.lessonType) {
        case 'video':
          videoCompletions++;
          break;
        case 'audio':
          audioCompletions++;
          break;
        case 'text':
          textCompletions++;
          break;
        case 'quiz':
          quizCompletions++;
          if (completion.scorePercentage != null) {
            quizScores.add(completion.scorePercentage!);
            if (completion.scorePercentage! > quizBestScore) {
              quizBestScore = completion.scorePercentage!;
            }
          }
          break;
        case 'flashcard':
          flashcardCompletions++;
          if (completion.scorePercentage != null) {
            flashcardScores.add(completion.scorePercentage!);
            if (completion.scorePercentage! > flashcardBestScore) {
              flashcardBestScore = completion.scorePercentage!;
            }
          }
          break;
      }
    }

    // Calculate filtered time spent
    for (final completion in filteredCompletions) {
      filteredTimeSpent += completion.durationSeconds ?? 0;
    }

    // Calculate separate average scores
    double quizAverageScore = 0.0;
    if (quizScores.isNotEmpty) {
      quizAverageScore = quizScores.reduce((a, b) => a + b) / quizScores.length;
    }

    double flashcardAverageScore = 0.0;
    if (flashcardScores.isNotEmpty) {
      flashcardAverageScore = flashcardScores.reduce((a, b) => a + b) / flashcardScores.length;
    }

    // Calculate weekly activity (last 7 days) - use all completions
    final weeklyActivity = _calculateWeeklyActivity(allCompletions);

    // Calculate course progress - use all completions so all courses show their progress
    final courseProgressResult = await _calculateCourseProgress(allCompletions);
    final courseProgressList = courseProgressResult.courseProgressList;
    final totalCourses = courseProgressResult.totalCourses;
    final completedCourses = courseProgressResult.completedCourses;
    final totalLessonsAvailable = courseProgressResult.totalLessonsAvailable;

    // Get recent completions (last 5)
    final recentCompletions = _getRecentCompletions(allCompletions, 5);

    return UserStatistics(
      totalCompletions: allCompletions.length,
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
      courseProgressList: courseProgressList,
      totalCourses: totalCourses,
      completedCourses: completedCourses,
      weeklyActivity: weeklyActivity,
      recentCompletions: recentCompletions,
      filteredCompletions: filteredCompletions.length,
      filteredTimeSpentSeconds: filteredTimeSpent,
      totalLessonsAvailable: totalLessonsAvailable,
    );
  }

  List<DailyActivity> _calculateWeeklyActivity(List<LessonCompletion> completions) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    final dailyData = <DateTime, _DailyData>{};

    // Initialize all 7 days
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);
      dailyData[normalizedDate] = _DailyData(0, 0);
    }

    // Aggregate completions by day
    for (final completion in completions) {
      final completionDate = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );

      if (dailyData.containsKey(completionDate)) {
        final existing = dailyData[completionDate]!;
        dailyData[completionDate] = _DailyData(
          existing.lessonsCompleted + 1,
          existing.timeSpentSeconds + (completion.durationSeconds ?? 0),
        );
      }
    }

    // Convert to DailyActivity list
    return dailyData.entries.map((entry) {
      return DailyActivity(
        date: entry.key,
        lessonsCompleted: entry.value.lessonsCompleted,
        timeSpentSeconds: entry.value.timeSpentSeconds,
      );
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<_CourseProgressResult> _calculateCourseProgress(List<LessonCompletion> completions) async {
    final courseProgressList = <CourseProgress>[];
    int totalCourses = 0;
    int completedCourses = 0;
    int totalLessonsAvailable = 0;

    try {
      final coursesResult = await courseRepository.getActiveCourses();

      coursesResult.fold(
        (failure) {
          // If we can't get courses, return empty progress
        },
        (courses) {
          totalCourses = courses.length;

          for (final course in courses) {
            // Use course.totalVideos which counts ALL lessons from sections
            // (despite the name, it counts all lesson types not just videos)
            final totalLessons = course.totalVideos;
            totalLessonsAvailable += totalLessons;

            // Count completions for this course
            final courseCompletions = completions
                .where((c) => c.courseId == course.id)
                .length;

            // Ensure we don't exceed total lessons
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
    } catch (e) {
      // Silently fail, return empty progress
    }

    return _CourseProgressResult(
      courseProgressList: courseProgressList,
      totalCourses: totalCourses,
      completedCourses: completedCourses,
      totalLessonsAvailable: totalLessonsAvailable,
    );
  }

  List<RecentCompletion> _getRecentCompletions(List<LessonCompletion> completions, int limit) {
    // Sort by completedAt descending and take the first 'limit' items
    final sorted = List<LessonCompletion>.from(completions)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return sorted.take(limit).map((completion) {
      return RecentCompletion(
        lessonId: completion.lessonId,
        lessonTitle: completion.lessonId, // We don't have the title, use ID
        lessonType: completion.lessonType ?? 'video',
        completedAt: completion.completedAt,
        scorePercentage: completion.scorePercentage,
      );
    }).toList();
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
