import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/network_info.dart';
import '../../../core/services/premium_service.dart';
import '../../../domain/entities/video.dart';
import '../../../domain/entities/section.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/usecases/download_usecases.dart';
import '../../../core/utils/localization_helper.dart';
import '../../../injection_container.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/lesson_completion/lesson_completion_bloc.dart';
import '../../bloc/lesson_completion/lesson_completion_event.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_state.dart' show CoursesLoaded, SelectedCourseLoaded, CourseSelected;
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/lesson_completion_dialog.dart';

/// Page for playing audio lessons (podcasts, guided meditations, etc.)
///
/// Features:
/// - Compact cover image display
/// - Audio playback with play/pause, seek bar
/// - Duration display
/// - Title and description below controls
/// - Scrollable content
/// - Banner ad at bottom
/// - Lesson completion dialog with next lesson navigation
class AudioLessonPage extends StatefulWidget {
  final Video lesson;
  final List<Section>? sections;

  const AudioLessonPage({
    super.key,
    required this.lesson,
    this.sections,
  });

  @override
  State<AudioLessonPage> createState() => _AudioLessonPageState();
}

class _AudioLessonPageState extends State<AudioLessonPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _error;
  bool _hasMarkedComplete = false;
  bool _hasShownCompletionDialog = false;
  bool _isPlayingOffline = false;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      // Check if audio is downloaded locally
      final getLocalVideoPath = sl<GetLocalVideoPath>();
      final localPathResult = await getLocalVideoPath(widget.lesson.id);
      String? localPath;
      localPathResult.fold(
        (failure) => localPath = null,
        (path) => localPath = path,
      );

      // Check network connectivity
      final networkInfo = sl<NetworkInfo>();
      final hasInternet = await networkInfo.isConnected;

      // Determine audio source
      String? audioSource;
      bool isLocalFile = false;

      if (localPath != null && await File(localPath!).exists()) {
        // Use local file for playback
        _isDownloaded = true;
        _isPlayingOffline = !hasInternet;
        audioSource = localPath;
        isLocalFile = true;
      } else if (hasInternet) {
        _isDownloaded = false;
        final audioUrl = widget.lesson.audioUrl;
        if (audioUrl == null || audioUrl.isEmpty) {
          setState(() {
            _error = 'No audio URL available';
            _isLoading = false;
          });
          return;
        }
        audioSource = audioUrl;
      } else {
        // Offline and not downloaded
        setState(() {
          _error = 'Audio not available offline. Download it first when online.';
          _isLoading = false;
        });
        return;
      }

      // Set up listeners
      _audioPlayer.onDurationChanged.listen((duration) {
        setState(() => _duration = duration);
      });

      _audioPlayer.onPositionChanged.listen((position) {
        setState(() => _position = position);
        _checkAudioProgress();
      });

      _audioPlayer.onPlayerStateChanged.listen((state) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading = state == PlayerState.stopped && _duration == Duration.zero;
        });
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() {
          _position = Duration.zero;
          _isPlaying = false;
        });
        // Show completion dialog when audio finishes
        if (!_hasShownCompletionDialog) {
          _hasShownCompletionDialog = true;
          _showCompletionDialog();
        }
      });

      // Load the audio
      if (isLocalFile) {
        await _audioPlayer.setSourceDeviceFile(audioSource!);
      } else {
        await _audioPlayer.setSourceUrl(audioSource!);
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Failed to load audio: $e';
        _isLoading = false;
      });
    }
  }

  void _checkAudioProgress() {
    if (_hasMarkedComplete) return;
    if (_duration.inMilliseconds == 0) return;

    final progress = _position.inMilliseconds / _duration.inMilliseconds;

    // Mark as complete if progress is 90% or more
    if (progress >= 0.9) {
      _hasMarkedComplete = true;
      context.read<LessonCompletionBloc>().add(
        MarkLessonCompleted(
          widget.lesson.id,
          courseId: widget.lesson.courseId,
          lessonType: 'audio',
          durationSeconds: widget.lesson.duration.inSeconds,
        ),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showCompletionDialog() {
    // Get the current course from CoursesBloc
    Course? currentCourse;
    try {
      final coursesState = context.read<CoursesBloc>().state;
      if (coursesState is CoursesLoaded) {
        // First try selectedCourse, then find by courseId
        currentCourse = coursesState.selectedCourse;
        if (currentCourse == null && widget.lesson.courseId != null) {
          currentCourse = coursesState.courses.where(
            (c) => c.id == widget.lesson.courseId,
          ).firstOrNull;
        }
      } else if (coursesState is SelectedCourseLoaded) {
        currentCourse = coursesState.course;
      } else if (coursesState is CourseSelected) {
        currentCourse = coursesState.course;
      }
    } catch (_) {
      // CoursesBloc not available
    }

    // Show the completion dialog
    LessonCompletionDialog.show(
      context: context,
      completedLesson: widget.lesson,
      course: currentCourse,
      sections: widget.sections ?? currentCourse?.sections,
    );
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  Future<void> _seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> _skip(int seconds) async {
    final newPosition = _position + Duration(seconds: seconds);
    if (newPosition.isNegative) {
      await _seek(Duration.zero);
    } else if (newPosition > _duration) {
      await _seek(_duration);
    } else {
      await _seek(newPosition);
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'download':
        _showDownloadDialog();
        break;
      case 'delete_download':
        _showDeleteDownloadDialog();
        break;
    }
  }

  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.download ?? 'Download Audio'),
        content: const Text('Download this audio for offline listening?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startDownload();
            },
            child: Text(AppLocalizations.of(context)?.download ?? 'Download'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.delete ?? 'Delete Download'),
        content: const Text('Are you sure you want to delete this downloaded audio? You will need to download it again to listen offline.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteDownload();
            },
            child: Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _startDownload() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download started...'),
          duration: Duration(seconds: 2),
        ),
      );

      final downloadVideo = sl<DownloadVideo>();
      final result = await downloadVideo(widget.lesson);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Download failed: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (downloadItem) {
          if (mounted) {
            final langCode = LocalizationHelper.getCurrentLanguageCode(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Downloading ${widget.lesson.getLocalizedTitle(langCode)}...'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteDownload() async {
    try {
      final getDownloadByVideoId = sl<GetDownloadByVideoId>();
      final result = await getDownloadByVideoId(widget.lesson.id);

      await result.fold(
        (failure) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to find download: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (downloadItem) async {
          if (downloadItem != null) {
            final deleteDownload = sl<DeleteDownload>();
            final deleteResult = await deleteDownload(downloadItem.id);

            deleteResult.fold(
              (failure) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: ${failure.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              (_) {
                if (mounted) {
                  setState(() {
                    _isDownloaded = false;
                    _isPlayingOffline = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Download deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final languageCode = LocalizationHelper.getCurrentLanguageCode(context);
    final title = widget.lesson.getLocalizedTitle(languageCode);
    final description = widget.lesson.getLocalizedDescription(languageCode);
    final thumbnailUrl = widget.lesson.thumbnailUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          // Offline indicator
          if (_isPlayingOffline)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.offline_bolt, color: Colors.orange, size: 16),
                  SizedBox(width: 4),
                  Text('Offline', style: TextStyle(color: Colors.orange, fontSize: 12)),
                ],
              ),
            ),
          // Download menu (only for premium users)
          if (PremiumService().isPremium)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleMenuAction(value),
              itemBuilder: (context) => [
                if (_isDownloaded)
                  PopupMenuItem(
                    value: 'delete_download',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)?.delete ?? 'Delete Download'),
                      ],
                    ),
                  )
                else
                  PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)?.download ?? 'Download'),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
      bottomNavigationBar: const SafeArea(
        child: BannerAdWidget(),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Player card with cover image inside
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surface.withValues(alpha: 0.8)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: isDark ? 0.1 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Cover image inside the card
                    _buildCoverImage(context, thumbnailUrl),
                    const SizedBox(height: 18),

                    // Error message
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: colorScheme.onErrorContainer,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    color: colorScheme.onErrorContainer,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Seek bar
                    if (_error == null) ...[
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: colorScheme.primary,
                          inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.2),
                          thumbColor: colorScheme.primary,
                          overlayColor: colorScheme.primary.withValues(alpha: 0.1),
                        ),
                        child: Slider(
                          value: _position.inMilliseconds.toDouble(),
                          max: _duration.inMilliseconds > 0
                              ? _duration.inMilliseconds.toDouble()
                              : 1,
                          onChanged: (value) {
                            _seek(Duration(milliseconds: value.toInt()));
                          },
                        ),
                      ),

                      // Time labels
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Controls
                      _buildControls(context),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Title and Description below controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context, String? thumbnailUrl) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildPlaceholder(context),
              errorWidget: (context, url, error) => _buildPlaceholder(context),
            )
          : _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Icon(
        Icons.headphones_rounded,
        size: 40,
        color: colorScheme.onPrimary.withValues(alpha: 0.9),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip backward 15s
        _buildControlButton(
          context,
          icon: Icons.replay_10_rounded,
          onPressed: _error == null ? () => _skip(-15) : null,
          size: 22,
          backgroundColor: colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.1),
          iconColor: colorScheme.primary,
        ),
        const SizedBox(width: 16),

        // Play/Pause
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primary,
          ),
          child: _isLoading
              ? Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _error == null ? _playPause : null,
                    customBorder: const CircleBorder(),
                    child: Center(
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 16),

        // Skip forward 30s
        _buildControlButton(
          context,
          icon: Icons.forward_30_rounded,
          onPressed: _error == null ? () => _skip(30) : null,
          size: 22,
          backgroundColor: colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.1),
          iconColor: colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
    required double size,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: size,
            color: onPressed != null
                ? iconColor
                : iconColor.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
