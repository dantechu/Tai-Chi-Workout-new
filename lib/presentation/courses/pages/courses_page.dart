import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/courses_bloc.dart';
import '../bloc/courses_event.dart';
import '../bloc/courses_state.dart';
import '../widgets/course_card.dart';
import 'course_detail_page.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  @override
  void initState() {
    super.initState();
    // Load courses when page is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoursesBloc>().add(const LoadCourses());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.courses ?? 'Courses'),
        elevation: 0,
        actions: [
          BlocBuilder<CoursesBloc, CoursesState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: AppLocalizations.of(context)?.refreshCourses ?? 'Refresh courses',
                onPressed: () {
                  context.read<CoursesBloc>().add(const RefreshCourses());
                },
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<CoursesBloc, CoursesState>(
        listener: (context, state) {
          if (state is CourseSelected) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.course.name} ${AppLocalizations.of(context)?.courseSelected ?? 'selected'}'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is CoursesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CoursesLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is CoursesError) {
            return _buildErrorState(context, state);
          }

          if (state is CoursesLoaded) {
            if (state.courses.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CoursesBloc>().add(const RefreshCourses());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: state.courses.length,
                itemBuilder: (context, index) {
                  final course = state.courses[index];
                  final isSelected = state.selectedCourse?.id == course.id;

                  return CourseCard(
                    course: course,
                    isSelected: isSelected,
                    onTap: () {
                      final coursesBloc = context.read<CoursesBloc>();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: coursesBloc,
                            child: CourseDetailPage(
                              course: course,
                              isSelected: isSelected,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, CoursesError state) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)?.errorLoadingCourses ?? 'Error Loading Courses',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<CoursesBloc>().add(const LoadCourses());
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)?.noCoursesAvailable ?? 'No Courses Available',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)?.checkBackLater ?? 'Check back later for new courses',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
