import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/course.dart';
import '../bloc/courses_bloc.dart';
import '../bloc/courses_event.dart';
import '../bloc/courses_state.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;
  final bool isSelected;

  const CourseDetailPage({
    super.key,
    required this.course,
    required this.isSelected,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CoursesBloc, CoursesState>(
      listener: (context, state) {
        if (state is CourseSelected) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.course.name} selected'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Navigate back to courses list
          Navigator.of(context).pop();
        } else if (state is CoursesError) {
          // Show error message
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Course Details'),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
               
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildStats(context),
                    const SizedBox(height: 24),
                    _buildBadges(context),
                    const SizedBox(height: 24),
                    _buildDescription(context),
                    if (widget.course.sections.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSections(context),
                    ],
                    const SizedBox(height: 80), // Space for bottom button
                  ],
                ),
              ),
            ),
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.course.name,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.isSelected) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: theme.colorScheme.onPrimary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Currently Selected',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              icon: Icons.video_library,
              label: 'Videos',
              value: '${widget.course.metadata.totalVideos}',
            ),
            _buildVerticalDivider(context),
            _buildStatItem(
              context,
              icon: Icons.view_module,
              label: 'Sections',
              value: '${widget.course.metadata.totalSections}',
            ),
            _buildVerticalDivider(context),
            _buildStatItem(
              context,
              icon: Icons.access_time,
              label: 'Duration',
              value: widget.course.metadata.formattedDuration,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha:0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      height: 60,
      width: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  Widget _buildBadges(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBadge(
          context,
          label: widget.course.isFree ? 'FREE' : 'PREMIUM',
          color: widget.course.isFree ? Colors.green : Colors.orange,
          icon: widget.course.isFree ? Icons.lock_open : Icons.star,
        ),
        if (widget.course.isDefault)
          _buildBadge(
            context,
            label: 'DEFAULT COURSE',
            color: Colors.blue,
            icon: Icons.bookmark,
          ),
        _buildBadge(
          context,
          label: '${widget.course.metadata.freeVideos} Free Videos',
          color: Colors.teal,
          icon: Icons.play_circle_outline,
        ),
        if (widget.course.metadata.premiumVideos > 0)
          _buildBadge(
            context,
            label: '${widget.course.metadata.premiumVideos} Premium Videos',
            color: Colors.deepOrange,
            icon: Icons.workspace_premium,
          ),
      ],
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha:0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.course.description.isEmpty) {
      return const SizedBox.shrink();
    }

    final description = widget.course.description;
    final shouldTruncate = description.length > 150;
    final displayText = shouldTruncate && !_isDescriptionExpanded
        ? '${description.substring(0, 150)}...'
        : description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About This Course',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          displayText,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        if (shouldTruncate) ...[
          const SizedBox(height: 4),
          InkWell(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                _isDescriptionExpanded ? 'View less' : 'View more',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSections(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Content',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.course.sections.map<Widget>((section) => _buildSectionCard(context, section)),
      ],
    );
  }

  Widget _buildSectionCard(BuildContext context, section) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${section.sectionNumber}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        title: Text(
          section.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${section.videos.length} videos • ${_formatDuration(section.totalDuration.inSeconds)}',
          style: theme.textTheme.bodySmall,
        ),
        children: [
          if (section.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                section.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: section.videos
                  .map<Widget>((video) => _buildVideoItem(context, video))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoItem(BuildContext context, video) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              video.title,
              style: theme.textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (video.isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'PRO',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(video.duration.inSeconds),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha:0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BlocBuilder<CoursesBloc, CoursesState>(
          builder: (context, state) {
            final isLoading = state is CoursesLoading;

            return SizedBox(
              width: double.infinity,
              height: 50,
              child: widget.isSelected
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Selected'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.primary),
                        foregroundColor: theme.colorScheme.primary,
                      ),
                    )
                  : FilledButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context
                                  .read<CoursesBloc>()
                                  .add(SelectCourseEvent(widget.course.id));
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Select This Course'),
                    ),
            );
          },
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
    return '${minutes}m ${remainingSeconds}s';
  }
}
