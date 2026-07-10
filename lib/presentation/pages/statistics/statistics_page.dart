import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
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
      floating: true,
      snap: true,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 56,
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
                    _buildTimeFilterDropdown(theme, currentFilter),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilterDropdown(ThemeData theme, StatisticsTimeFilter currentFilter) {
    final filters = {
      StatisticsTimeFilter.today: 'Today',
      StatisticsTimeFilter.thisWeek: 'This Week',
      StatisticsTimeFilter.thisMonth: 'This Month',
      StatisticsTimeFilter.allTime: 'All Time',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<StatisticsTimeFilter>(
          value: currentFilter,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
          isDense: true,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
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
          // Current Course section
          Text(
            'Current Course',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildCurrentCourseProgressCard(theme, selectedCourse, stats),
          const SizedBox(height: 24),

          // Weekly activity chart
          _buildWeeklyActivitySection(theme, stats),
          const SizedBox(height: 24),

          // Lesson type breakdown with pie chart
          _buildLessonTypeSection(theme, l10n, stats),
          const SizedBox(height: 24),

          // Course progress section
          if (stats.courseProgressList.isNotEmpty)
            _buildCourseProgressSection(theme, stats),

          // Score section (if quiz/flashcard completed)
          if (stats.quizCompletions > 0 || stats.flashcardCompletions > 0) ...[
            const SizedBox(height: 24),
            _buildScoreSection(theme, l10n, stats),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCurrentCourseProgressCard(ThemeData theme, CourseProgress? selectedCourse, UserStatistics stats) {
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
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Select a course to see progress',
              style: TextStyle(
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
                      isCompleted ? 'Done!' : 'Complete',
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
                  'Lessons',
                ),
                const SizedBox(height: 8),
                _buildProgressStat(
                  Icons.access_time_rounded,
                  stats.formattedTotalTime,
                  'Total Time',
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

  Widget _buildWeeklyActivitySection(ThemeData theme, UserStatistics stats) {
    final hasData = stats.weeklyActivity.any((a) => a.lessonsCompleted > 0);
    final maxLessons = stats.weeklyActivity.isEmpty
        ? 1.0
        : stats.weeklyActivity.map((a) => a.lessonsCompleted).reduce(math.max).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Activity',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: hasData
              ? BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxLessons + 1,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => theme.colorScheme.surfaceContainerHighest,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final activity = stats.weeklyActivity[group.x.toInt()];
                          return BarTooltipItem(
                            '${activity.lessonsCompleted} lessons',
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
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  stats.weeklyActivity[value.toInt()].dayLabel,
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
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: stats.weeklyActivity.asMap().entries.map((entry) {
                      final index = entry.key;
                      final activity = entry.value;
                      final isToday = index == stats.weeklyActivity.length - 1;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: activity.lessonsCompleted.toDouble(),
                            color: isToday
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary.withValues(alpha: 0.5),
                            width: 24,
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
                        'No activity this week',
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
      (_LessonTypeData(Icons.play_circle_rounded, Colors.blue, 'Video', stats.videoCompletions)),
      (_LessonTypeData(Icons.headphones_rounded, Colors.purple, 'Audio', stats.audioCompletions)),
      (_LessonTypeData(Icons.article_rounded, Colors.teal, 'Text', stats.textCompletions)),
      (_LessonTypeData(Icons.quiz_rounded, Colors.orange, 'Quiz', stats.quizCompletions)),
      (_LessonTypeData(Icons.style_rounded, Colors.pink, 'Flashcards', stats.flashcardCompletions)),
    ];

    // Filter out types with 0 completions for the pie chart
    final pieData = types.where((t) => t.count > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'By Lesson Type',
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
                          'Complete lessons to see breakdown',
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

  Widget _buildCourseProgressSection(ThemeData theme, UserStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Course Progress',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${stats.completedCourses}/${stats.totalCourses} completed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...stats.courseProgressList.map((course) => _buildCourseProgressTile(theme, course)),
      ],
    );
  }

  Widget _buildCourseProgressTile(ThemeData theme, CourseProgress course) {
    final progress = course.progressPercentage / 100;
    final isCompleted = course.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: isCompleted
            ? Border.all(color: Colors.green.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.check, color: Colors.green, size: 14),
                ),
              Expanded(
                child: Text(
                  course.courseName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${course.completedLessons}/${course.totalLessons}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCompleted
                          ? [Colors.green, Colors.green.shade400]
                          : [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection(ThemeData theme, AppLocalizations? l10n, UserStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quiz & Flashcard Scores',
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
                iconColor: Colors.blue,
                label: 'Average',
                score: stats.averageScore,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildScoreCard(
                theme,
                icon: Icons.emoji_events_rounded,
                iconColor: Colors.amber,
                label: 'Best',
                score: stats.bestScore.toDouble(),
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
  }) {
    // Determine color based on score
    Color scoreColor;
    if (score >= 80) {
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
            '${score.toInt()}%',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonTypeData {
  final IconData icon;
  final Color color;
  final String label;
  final int count;

  _LessonTypeData(this.icon, this.color, this.label, this.count);
}
