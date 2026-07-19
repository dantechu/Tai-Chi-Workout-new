import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/certificate_service.dart';
import '../../../domain/entities/course.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_state.dart';
import 'certificate_name_page.dart';
import 'certificate_view_page.dart';

class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  final CertificateService _certificateService = CertificateService();
  List<String> _completedCourseIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompletedCourses();
  }

  Future<void> _loadCompletedCourses() async {
    final completedIds = await _certificateService.getCompletedCourseIds();
    setState(() {
      _completedCourseIds = completedIds;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
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
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              l10n?.certificates ?? 'Certificates',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: true,
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            BlocBuilder<CoursesBloc, CoursesState>(
              builder: (context, state) {
                if (state is! CoursesLoaded) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Filter courses that are completed and have certificates
                final coursesWithCertificates = state.courses.where((course) {
                  return _completedCourseIds.contains(course.id) && course.hasCertificate;
                }).toList();

                if (coursesWithCertificates.isEmpty) {
                  return SliverFillRemaining(
                    child: _buildEmptyState(context),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final course = coursesWithCertificates[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCertificateCard(context, course),
                        );
                      },
                      childCount: coursesWithCertificates.length,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber.withValues(alpha: 0.15),
                    Colors.orange.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 64,
                color: Colors.amber.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n?.noCertificatesYet ?? 'No Certificates Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.completeCourseForCertificate ?? 'Complete a course to earn your certificate',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateCard(BuildContext context, Course course) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : theme.colorScheme.outline.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openCertificate(context, course),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.amber, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.getLocalizedName(
                              Localizations.localeOf(context).languageCode,
                            ),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n?.certificateAvailable ?? 'Certificate Available',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCertificate(BuildContext context, Course course) async {
    final hasName = await _certificateService.hasEnteredName();
    final userName = await _certificateService.getCertificateName();

    if (!context.mounted) return;

    if (hasName && userName != null) {
      // Go directly to certificate view
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CertificateViewPage(
            course: course,
            userName: userName,
          ),
        ),
      );
    } else {
      // Go to name entry page first
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CertificateNamePage(course: course),
        ),
      );
    }
  }
}
