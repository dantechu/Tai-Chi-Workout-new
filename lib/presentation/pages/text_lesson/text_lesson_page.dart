import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/video.dart';
import '../../../core/utils/quill_delta_parser.dart';
import '../../../core/utils/localization_helper.dart';

/// Page for displaying text/article lessons.
///
/// Features:
/// - Banner image at the top (if available)
/// - Rich text content rendered from Quill Delta JSON
/// - Estimated read time display
/// - Support for multilingual content
class TextLessonPage extends StatelessWidget {
  final Video lesson;

  const TextLessonPage({
    super.key,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = LocalizationHelper.getCurrentLanguageCode(context);
    final title = lesson.getLocalizedTitle(languageCode);
    final content = lesson.getLocalizedContent(languageCode) ?? '';
    final description = lesson.getLocalizedDescription(languageCode);
    final bannerUrl = lesson.bannerUrl;
    final readTimeMinutes = ((lesson.estimatedReadTime ?? lesson.duration.inSeconds) / 60).ceil();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with banner image
          SliverAppBar(
            expandedHeight: bannerUrl != null ? 250 : 0,
            pinned: true,
            flexibleSpace: bannerUrl != null
                ? FlexibleSpaceBar(
                    background: _buildBannerImage(bannerUrl),
                  )
                : null,
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // TODO: Implement share
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (if no banner)
                  if (bannerUrl == null) ...[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Read time badge
                  _buildReadTimeBadge(context, readTimeMinutes),
                  const SizedBox(height: 16),

                  // Description (if available)
                  if (description != null && description.isNotEmpty) ...[
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Divider(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Main content
                  _buildContent(context, content),
                ],
              ),
            ),
          ),

          // Bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildBannerImage(String url) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.withValues(alpha: 0.3),
            child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
          ),
        ),
        // Gradient overlay for better text readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadTimeBadge(BuildContext context, int minutes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 16,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            '$minutes min read',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, String content) {
    if (content.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.article_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No content available',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // Check if content is Quill Delta JSON
    if (QuillDeltaParser.isQuillDelta(content)) {
      final widgets = QuillDeltaParser.buildWidgets(
        content,
        baseStyle: Theme.of(context).textTheme.bodyLarge,
        linkColor: Theme.of(context).colorScheme.primary,
        imageMaxWidth: MediaQuery.of(context).size.width - 32,
        paragraphPadding: const EdgeInsets.symmetric(vertical: 8),
        blockquoteColor: Theme.of(context).colorScheme.primary,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      );
    }

    // Plain text fallback
    return Text(
      content,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
          ),
    );
  }
}
