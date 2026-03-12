import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/localization_helper.dart';
import '../../../l10n/app_localizations.dart';
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
          final langCode = LocalizationHelper.getCurrentLanguageCode(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.course.getLocalizedName(langCode)} selected'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.courseDetails ?? 'Course Details'),
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    _buildStats(context),
                    const SizedBox(height: 20),
                    _buildBadges(context),
                    const SizedBox(height: 20),
                    _buildDescription(context),
                    if (widget.course.sections.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSections(context),
                    ],
                    const SizedBox(height: 90),
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
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.course.getLocalizedName(langCode),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        if (widget.isSelected) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  AppLocalizations.of(context)?.currentlySelected ?? 'Currently Selected',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            icon: Icons.video_library_outlined,
            label: AppLocalizations.of(context)?.videos ?? 'Videos',
            value: '${widget.course.metadata.totalVideos}',
          ),
          _buildVerticalDivider(context),
          _buildStatItem(
            context,
            icon: Icons.view_module_outlined,
            label: AppLocalizations.of(context)?.sections ?? 'Sections',
            value: '${widget.course.metadata.totalSections}',
          ),
          _buildVerticalDivider(context),
          _buildStatItem(
            context,
            icon: Icons.access_time_outlined,
            label: AppLocalizations.of(context)?.duration ?? 'Duration',
            value: widget.course.metadata.formattedDuration,
          ),
        ],
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
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      height: 50,
      width: 1,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }

  Widget _buildBadges(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBadge(
          context,
          label: widget.course.isFree
              ? (AppLocalizations.of(context)?.free ?? 'Free')
              : (AppLocalizations.of(context)?.premium ?? 'Premium'),
          color: widget.course.isFree ? Colors.green : Colors.orange,
          icon: widget.course.isFree ? Icons.lock_open : Icons.workspace_premium,
        ),
        if (widget.course.isDefault)
          _buildBadge(
            context,
            label: AppLocalizations.of(context)?.defaultBadge ?? 'Default',
            color: Colors.blue,
            icon: Icons.bookmark,
          ),
        _buildBadge(
          context,
          label: '${widget.course.metadata.freeVideos} ${AppLocalizations.of(context)?.free ?? 'Free'}',
          color: Colors.teal,
          icon: Icons.play_circle_outline,
        ),
        if (widget.course.metadata.premiumVideos > 0)
          _buildBadge(
            context,
            label: '${widget.course.metadata.premiumVideos} ${AppLocalizations.of(context)?.premium ?? 'Premium'}',
            color: Colors.deepOrange,
            icon: Icons.star_outline,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);
    final description = widget.course.getLocalizedDescription(langCode);

    if (description.isEmpty) {
      return const SizedBox.shrink();
    }

    final shouldTruncate = description.length > 150;
    final displayText = shouldTruncate && !_isDescriptionExpanded
        ? '${description.substring(0, 150)}...'
        : description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.aboutThisCourse ?? 'About This Course',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          displayText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
            height: 1.6,
            fontSize: 14,
          ),
        ),
        if (shouldTruncate) ...[
          const SizedBox(height: 6),
          InkWell(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Text(
                _isDescriptionExpanded
                    ? (AppLocalizations.of(context)?.viewLess ?? 'View less')
                    : (AppLocalizations.of(context)?.viewMore ?? 'View more'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
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
          AppLocalizations.of(context)?.courseContent ?? 'Course Content',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.course.sections.map<Widget>(
          (section) => _buildSectionCard(context, section),
        ),
      ],
    );
  }

  Widget _buildSectionCard(BuildContext context, section) {
    final theme = Theme.of(context);
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.only(bottom: 12),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${section.sectionNumber}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 14,
              ),
            ),
          ),
        ),
        title: Text(
          section.getLocalizedTitle(langCode),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${AppLocalizations.of(context)?.videosCount(section.videos.length) ?? '${section.videos.length} videos'} • ${_formatDuration(section.totalDuration.inSeconds)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ),
        children: [
          if (section.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                section.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                  fontSize: 13,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 18,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              video.getLocalizedTitle(langCode),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (video.isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'PRO',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(video.duration.inSeconds),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: BlocBuilder<CoursesBloc, CoursesState>(
          builder: (context, state) {
            final isLoading = state is CoursesLoading;

            return SizedBox(
              width: double.infinity,
              height: 48,
              child: widget.isSelected
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: Icon(
                        Icons.check_circle,
                        size: 18,
                      ),
                      label: Text(
                        AppLocalizations.of(context)?.selected ?? 'Selected',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        foregroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)?.selectThisCourse ?? 'Select This Course',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
