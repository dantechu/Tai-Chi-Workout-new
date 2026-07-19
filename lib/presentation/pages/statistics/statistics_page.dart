import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/user_statistics.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/statistics/statistics_bloc.dart';
import '../../bloc/statistics/statistics_event.dart';
import '../../bloc/statistics/statistics_state.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_state.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    // Get the selected course from CoursesBloc if available
    String? selectedCourseId;
    try {
      final coursesState = context.read<CoursesBloc>().state;
      if (coursesState is CoursesLoaded && coursesState.selectedCourse != null) {
        selectedCourseId = coursesState.selectedCourse!.id;
      }
    } catch (_) {
      // CoursesBloc not available, proceed without selected course
    }

    context.read<StatisticsBloc>().add(LoadStatistics(courseId: selectedCourseId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: BlocListener<CoursesBloc, CoursesState>(
        listener: (context, coursesState) {
          // Refresh statistics when course selection changes
          if (coursesState is CoursesLoaded && coursesState.selectedCourse != null) {
            context.read<StatisticsBloc>().add(
              ChangeCourseFilter(coursesState.selectedCourse!.id),
            );
          }
        },
        child: BlocBuilder<StatisticsBloc, StatisticsState>(
          builder: (context, state) {
            final currentFilter = state is StatisticsLoaded
                ? state.currentFilter
                : StatisticsTimeFilter.allTime;

            return CustomScrollView(
              slivers: [
                _buildAppBar(theme, l10n, currentFilter),
                SliverToBoxAdapter(
                  child: Builder(
                    builder: (context) {
                      if (state is StatisticsLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(48.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (state is StatisticsError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(48.0),
                            child: Column(
                              children: [
                                Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                                const SizedBox(height: 16),
                                Text(state.message),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.read<StatisticsBloc>().add(const RefreshStatistics()),
                                  child: Text(l10n?.retry ?? 'Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is StatisticsLoaded) {
                        return _buildContent(theme, l10n, state);
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, AppLocalizations? l10n, StatisticsTimeFilter currentFilter) {
    final isDark = theme.brightness == Brightness.dark;

    return SliverAppBar(
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 50,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface.withValues(alpha: 0.9),
                  theme.colorScheme.surface.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.analytics_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n?.statisticsTab ?? 'Statistics',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _buildTimeFilterDropdown(theme, l10n, currentFilter),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilterDropdown(ThemeData theme, AppLocalizations? l10n, StatisticsTimeFilter currentFilter) {
    final filters = {
      StatisticsTimeFilter.today: l10n?.filterToday ?? 'Today',
      StatisticsTimeFilter.thisWeek: l10n?.filterThisWeek ?? 'This Week',
      StatisticsTimeFilter.thisMonth: l10n?.filterThisMonth ?? 'This Month',
      StatisticsTimeFilter.allTime: l10n?.filterAllTime ?? 'All Time',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<StatisticsTimeFilter>(
          value: currentFilter,
          icon: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
          ),
          isDense: true,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          items: filters.entries.map((entry) {
            return DropdownMenuItem<StatisticsTimeFilter>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<StatisticsBloc>().add(ChangeTimeFilter(value));
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, AppLocalizations? l10n, StatisticsLoaded state) {
    final stats = state.statistics;

    // Find the selected course progress
    CourseProgress? selectedCourse;
    if (state.selectedCourseId != null && stats.courseProgressList.isNotEmpty) {
      selectedCourse = stats.courseProgressList.firstWhere(
        (c) => c.courseId == state.selectedCourseId,
        orElse: () => stats.courseProgressList.first,
      );
    } else if (stats.courseProgressList.isNotEmpty) {
      selectedCourse = stats.courseProgressList.first;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Course Progress section (at top)
          Text(
            l10n?.currentCourseProgress ?? 'Current Course Progress',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildCurrentCourseProgressCard(theme, l10n, selectedCourse, stats),
          const SizedBox(height: 24),

          // Streak & Pace Section
          _buildStreakAndPaceSection(theme, l10n, stats),
          const SizedBox(height: 24),

          // Weekly activity chart
          _buildWeeklyActivitySection(theme, l10n, Localizations.localeOf(context).languageCode, stats),
          const SizedBox(height: 24),

          // Time Efficiency Section (NEW)
          if (stats.totalCompletions > 0)
            _buildTimeEfficiencySection(theme, l10n, stats),
          if (stats.totalCompletions > 0)
            const SizedBox(height: 24),

          // Lesson type breakdown with pie chart
          _buildLessonTypeSection(theme, l10n, stats),
          const SizedBox(height: 24),

          // Course progress section
          if (stats.courseProgressList.isNotEmpty)
            _buildCourseProgressSection(theme, l10n, stats),

          // Quiz accuracy section (only if quiz completed)
          if (stats.quizCompletions > 0) ...[
            const SizedBox(height: 24),
            _buildQuizAccuracySection(theme, l10n, stats),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCurrentCourseProgressCard(ThemeData theme, AppLocalizations? l10n, CourseProgress? selectedCourse, UserStatistics stats) {
    // If no course selected, show a placeholder
    if (selectedCourse == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              l10n?.selectCourseToSeeProgress ?? 'Select a course to see progress',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      );
    }

    final progress = selectedCourse.progressPercentage / 100;
    final isCompleted = selectedCourse.isCompleted;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCompleted
              ? [Colors.green.shade600, Colors.green.shade400]
              : [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Circular progress indicator
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isCompleted)
                      const Icon(Icons.check_circle, color: Colors.white, size: 28)
                    else
                      Text(
                        '${selectedCourse.progressPercentage.toInt()}%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    Text(
                      isCompleted ? (l10n?.done ?? 'Done!') : (l10n?.complete ?? 'Complete'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedCourse.courseName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                _buildProgressStat(
                  Icons.menu_book_rounded,
                  '${selectedCourse.completedLessons}/${selectedCourse.totalLessons}',
                  l10n?.lessons ?? 'Lessons',
                ),
                const SizedBox(height: 8),
                _buildProgressStat(
                  Icons.access_time_rounded,
                  stats.formattedTotalTime,
                  l10n?.totalTime ?? 'Total Time',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyActivitySection(ThemeData theme, AppLocalizations? l10n, String localeCode, UserStatistics stats) {
    final hasData = stats.weeklyActivity.any((a) => a.timeSpentSeconds > 0);
    // Convert to minutes for easier display
    final maxMinutes = stats.weeklyActivity.isEmpty
        ? 1.0
        : stats.weeklyActivity.map((a) => a.timeSpentSeconds / 60.0).reduce(math.max);
    // Round up to nearest 5 or 10 minutes for cleaner Y-axis
    final yAxisMax = maxMinutes < 5 ? 5.0 : ((maxMinutes / 5).ceil() * 5.0 + 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.last7Days ?? 'Last 7 Days',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.only(left: 8, right: 16, top: 16, bottom: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: hasData
              ? BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: yAxisMax,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => theme.colorScheme.surfaceContainerHighest,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final activity = stats.weeklyActivity[group.x.toInt()];
                          final minutes = activity.timeSpentSeconds ~/ 60;
                          final hours = minutes ~/ 60;
                          final remainingMins = minutes % 60;
                          final timeStr = hours > 0
                              ? '${hours}h ${remainingMins}m'
                              : '${minutes}m';
                          return BarTooltipItem(
                            '$timeStr\n${activity.lessonsCompleted} lessons',
                            TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < stats.weeklyActivity.length) {
                              final date = stats.weeklyActivity[value.toInt()].date;
                              final dayName = DateFormat.E(localeCode).format(date);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  dayName,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: yAxisMax / 4,
                          getTitlesWidget: (value, meta) {
                            final minutes = value.toInt();
                            final hours = minutes ~/ 60;
                            final remainingMins = minutes % 60;
                            String label;
                            if (minutes == 0) {
                              label = '0m';
                            } else if (hours > 0 && remainingMins == 0) {
                              label = '${hours}h';
                            } else if (hours > 0) {
                              label = '${hours}h${remainingMins}m';
                            } else {
                              label = '${minutes}m';
                            }
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                label,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: yAxisMax / 4,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: stats.weeklyActivity.asMap().entries.map((entry) {
                      final index = entry.key;
                      final activity = entry.value;
                      final isToday = index == stats.weeklyActivity.length - 1;
                      final minutes = activity.timeSpentSeconds / 60.0;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: minutes,
                            color: isToday
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary.withValues(alpha: 0.5),
                            width: 20,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        size: 48,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n?.noActivityThisWeek ?? 'No activity this week',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildLessonTypeSection(ThemeData theme, AppLocalizations? l10n, UserStatistics stats) {
    final hasData = stats.totalCompletions > 0;

    // Colors match video_card.dart for consistency across the app
    final types = [
      (_LessonTypeData(Icons.play_circle_rounded, Colors.blue, l10n?.lessonTypeVideo ?? 'Video', stats.videoCompletions)),
      (_LessonTypeData(Icons.headphones_rounded, Colors.purple, l10n?.lessonTypeAudio ?? 'Audio', stats.audioCompletions)),
      (_LessonTypeData(Icons.article_rounded, Colors.teal, l10n?.lessonTypeText ?? 'Text', stats.textCompletions)),
      (_LessonTypeData(Icons.quiz_rounded, Colors.orange, l10n?.lessonTypeQuiz ?? 'Quiz', stats.quizCompletions)),
      (_LessonTypeData(Icons.style_rounded, Colors.pink, l10n?.lessonTypeFlashcards ?? 'Flashcards', stats.flashcardCompletions)),
    ];

    // Filter out types with 0 completions for the pie chart
    final pieData = types.where((t) => t.count > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.lessonBreakdown ?? 'Lesson Breakdown',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: hasData && pieData.isNotEmpty
              ? Row(
                  children: [
                    // Pie chart
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: pieData.map((type) {
                            final percentage = (type.count / stats.totalCompletions) * 100;
                            return PieChartSectionData(
                              value: type.count.toDouble(),
                              color: type.color,
                              radius: 30,
                              title: percentage >= 10 ? '${percentage.toInt()}%' : '',
                              titleStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Legend
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: types.map((type) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: type.color,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    type.label,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                                Text(
                                  '${type.count}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.pie_chart_rounded,
                          size: 48,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n?.completeLessonsToSeeBreakdown ?? 'Complete lessons to see breakdown',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCourseProgressSection(ThemeData theme, AppLocalizations? l10n, UserStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.allCourses ?? 'All Courses',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ...stats.courseProgressList.asMap().entries.map((entry) {
                final isLast = entry.key == stats.courseProgressList.length - 1;
                return _buildCourseProgressTile(theme, l10n, entry.value, entry.key + 1, isLast);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseProgressTile(ThemeData theme, AppLocalizations? l10n, CourseProgress course, int index, bool isLast) {
    final progress = course.progressPercentage / 100;
    final isCompleted = course.isCompleted;
    final progressColor = isCompleted ? Colors.green : theme.colorScheme.primary;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // Index number
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$index',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Course info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.courseName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course.completedLessons}/${course.totalLessons} ${l10n?.lessons ?? 'lessons'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Circular progress with percentage
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                    if (isCompleted)
                      Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: progressColor,
                      )
                    else
                      Text(
                        '${course.progressPercentage.toInt()}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 2,
            thickness: 2,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
      ],
    );
  }

  Widget _buildQuizAccuracySection(ThemeData theme, AppLocalizations? l10n, UserStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.quizzesAccuracy ?? 'Quizzes Accuracy',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildScoreCard(
                theme,
                icon: Icons.trending_up_rounded,
                iconColor: Colors.orange,
                label: l10n?.average ?? 'Average',
                score: stats.quizAverageScore,
                completions: stats.quizCompletions,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildScoreCard(
                theme,
                icon: Icons.emoji_events_rounded,
                iconColor: Colors.amber,
                label: l10n?.best ?? 'Best',
                score: stats.quizBestScore.toDouble(),
                completions: stats.quizCompletions,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreCard(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required double score,
    required int completions,
  }) {
    final hasData = completions > 0;

    // Determine color based on score
    Color scoreColor;
    if (!hasData) {
      scoreColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
    } else if (score >= 80) {
      scoreColor = Colors.green;
    } else if (score >= 60) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hasData ? '${score.toInt()}%' : '-',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakAndPaceSection(ThemeData theme, AppLocalizations? l10n, UserStatistics stats) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Streak Card
          Expanded(
            child: _buildStreakCard(theme, l10n, stats),
          ),
          const SizedBox(width: 12),
          // Pace Card
          Expanded(
            child: _buildPaceCard(theme, l10n, stats),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(ThemeData theme, AppLocalizations? l10n, UserStatistics stats) {
    final hasStreak = stats.currentStreak > 0;
    final isAtRisk = stats.streakAtRisk;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasStreak ? Icons.local_fire_department_rounded : Icons.local_fire_department_outlined,
                size: 28,
                color: hasStreak ? Colors.orange : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n?.streak ?? 'Streak',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${stats.currentStreak}',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: hasStreak ? Colors.orange : theme.colorScheme.onSurface,
            ),
          ),
          Text(
            stats.currentStreak == 1 ? (l10n?.day ?? 'day') : (l10n?.days ?? 'days'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (stats.longestStreak > stats.currentStreak) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n?.best ?? 'Best'}: ${stats.longestStreak} ${l10n?.days ?? 'days'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (isAtRisk) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n?.streakAtRisk ?? 'Complete a lesson today!',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaceCard(ThemeData theme, AppLocalizations? l10n, UserStatistics stats) {
    final hasData = stats.totalCompletions > 0;
    final weeklyAvg = stats.weeklyAverageLessonsPerDay;
    final allTimeAvg = stats.averageLessonsPerDay;

    // Determine trend color
    Color trendColor;
    IconData trendIcon;
    switch (stats.paceTrend) {
      case 1:
        trendColor = Colors.green;
        trendIcon = Icons.trending_up_rounded;
        break;
      case -1:
        trendColor = Colors.red;
        trendIcon = Icons.trending_down_rounded;
        break;
      default:
        trendColor = Colors.blue;
        trendIcon = Icons.trending_flat_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed_rounded,
                size: 24,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n?.pace ?? 'Pace',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasData) ...[
            Text(
              '${weeklyAvg.ceil()}',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              weeklyAvg.ceil() == 1 ? (l10n?.lessonPerDay ?? 'lesson/day') : (l10n?.lessonsPerDay ?? 'lessons/day'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (stats.daysSinceFirstLesson >= 7) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(trendIcon, size: 16, color: trendColor),
                  const SizedBox(width: 4),
                  Text(
                    _getLocalizedPaceTrend(l10n, stats.paceTrend),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: trendColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            if (allTimeAvg.ceil() != weeklyAvg.ceil() && stats.daysSinceFirstLesson >= 7) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n?.allTime ?? 'All time'}: ${allTimeAvg.ceil()}/${l10n?.day ?? 'day'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ] else ...[
            Text(
              '-',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            Text(
              l10n?.noDataYet ?? 'No data yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeEfficiencySection(ThemeData theme, AppLocalizations? l10n, UserStatistics stats) {
    // Only show types that have been completed
    final efficiencyData = <_TimeEfficiencyData>[];

    if (stats.videoCompletions > 0) {
      efficiencyData.add(_TimeEfficiencyData(
        Icons.play_circle_rounded,
        Colors.blue,
        l10n?.lessonTypeVideo ?? 'Video',
        stats.avgTimePerVideo,
        stats.videoCompletions,
      ));
    }
    if (stats.audioCompletions > 0) {
      efficiencyData.add(_TimeEfficiencyData(
        Icons.headphones_rounded,
        Colors.purple,
        l10n?.lessonTypeAudio ?? 'Audio',
        stats.avgTimePerAudio,
        stats.audioCompletions,
      ));
    }
    if (stats.textCompletions > 0) {
      efficiencyData.add(_TimeEfficiencyData(
        Icons.article_rounded,
        Colors.teal,
        l10n?.lessonTypeText ?? 'Text',
        stats.avgTimePerText,
        stats.textCompletions,
      ));
    }
    if (stats.quizCompletions > 0) {
      efficiencyData.add(_TimeEfficiencyData(
        Icons.quiz_rounded,
        Colors.orange,
        l10n?.lessonTypeQuiz ?? 'Quiz',
        stats.avgTimePerQuiz,
        stats.quizCompletions,
      ));
    }
    if (stats.flashcardCompletions > 0) {
      efficiencyData.add(_TimeEfficiencyData(
        Icons.style_rounded,
        Colors.pink,
        l10n?.lessonTypeFlashcards ?? 'Flashcards',
        stats.avgTimePerFlashcard,
        stats.flashcardCompletions,
      ));
    }

    if (efficiencyData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.timePerLesson ?? 'Time per Lesson',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: efficiencyData.map((data) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: data.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(data.icon, color: data.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            l10n?.nLessons(data.count) ?? '${data.count} lessons',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      stats.formatAvgTime(data.avgTimeSeconds),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: data.color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getLocalizedPaceTrend(AppLocalizations? l10n, int paceTrend) {
    switch (paceTrend) {
      case 1:
        return l10n?.accelerating ?? 'Accelerating';
      case -1:
        return l10n?.slowing ?? 'Slowing';
      default:
        return l10n?.steady ?? 'Steady';
    }
  }
}

class _LessonTypeData {
  final IconData icon;
  final Color color;
  final String label;
  final int count;

  _LessonTypeData(this.icon, this.color, this.label, this.count);
}

class _TimeEfficiencyData {
  final IconData icon;
  final Color color;
  final String label;
  final int avgTimeSeconds;
  final int count;

  _TimeEfficiencyData(this.icon, this.color, this.label, this.avgTimeSeconds, this.count);
}
