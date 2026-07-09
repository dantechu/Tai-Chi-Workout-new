import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/video.dart';
import '../../../core/utils/localization_helper.dart';

/// Page for playing audio lessons (podcasts, guided meditations, etc.)
///
/// Features:
/// - Cover image display
/// - Audio playback with play/pause, seek bar
/// - Duration display
/// - Background playback support
class AudioLessonPage extends StatefulWidget {
  final Video lesson;

  const AudioLessonPage({
    super.key,
    required this.lesson,
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

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    final audioUrl = widget.lesson.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) {
      setState(() {
        _error = 'No audio URL available';
        _isLoading = false;
      });
      return;
    }

    try {
      // Set up listeners
      _audioPlayer.onDurationChanged.listen((duration) {
        setState(() => _duration = duration);
      });

      _audioPlayer.onPositionChanged.listen((position) {
        setState(() => _position = position);
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
      });

      // Load the audio
      await _audioPlayer.setSourceUrl(audioUrl);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Failed to load audio: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final languageCode = LocalizationHelper.getCurrentLanguageCode(context);
    final title = widget.lesson.getLocalizedTitle(languageCode);
    final description = widget.lesson.getLocalizedDescription(languageCode);
    final thumbnailUrl = widget.lesson.thumbnailUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Lesson'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Cover image
              _buildCoverImage(thumbnailUrl),
              const SizedBox(height: 32),

              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Description
              if (description != null && description.isNotEmpty)
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

              const Spacer(),

              // Error message
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Progress bar
              if (_error == null) ...[
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                    activeTrackColor: Theme.of(context).colorScheme.primary,
                    inactiveTrackColor:
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    thumbColor: Theme.of(context).colorScheme.primary,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Controls
                _buildControls(),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(String? thumbnailUrl) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildPlaceholder(),
              errorWidget: (context, url, error) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        Icons.headphones,
        size: 80,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip backward
        IconButton(
          onPressed: _error == null ? () => _skip(-15) : null,
          icon: const Icon(Icons.replay_10),
          iconSize: 36,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 16),

        // Play/Pause
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : IconButton(
                  onPressed: _error == null ? _playPause : null,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 40,
                  ),
                ),
        ),
        const SizedBox(width: 16),

        // Skip forward
        IconButton(
          onPressed: _error == null ? () => _skip(30) : null,
          icon: const Icon(Icons.forward_30),
          iconSize: 36,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ],
    );
  }
}
