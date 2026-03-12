import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import '../../../l10n/app_localizations.dart';

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  int _currentTrackIndex = 0;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 5);
  static const int _trackCount = 4;

  List<MusicTrack> _getTracks(BuildContext context) {
    return [
      MusicTrack(
        title: AppLocalizations.of(context)?.trackPeacefulMorning ?? 'Peaceful Morning',
        artist: AppLocalizations.of(context)?.artistAmbientMeditation ?? 'Ambient Meditation',
        duration: const Duration(minutes: 5, seconds: 32),
        albumArt: '🌅',
        color: const Color(0xFFFF6B6B),
        audioPath: 'audio/music/peaceful_morning.mp3',
      ),
      MusicTrack(
        title: AppLocalizations.of(context)?.trackFlowingWater ?? 'Flowing Water',
        artist: AppLocalizations.of(context)?.artistDeepRelaxation ?? 'Deep Relaxation',
        duration: const Duration(minutes: 7, seconds: 18),
        albumArt: '🌊',
        color: const Color(0xFF4ECDC4),
        audioPath: 'audio/music/flowing_water.mp3',
      ),
      MusicTrack(
        title: AppLocalizations.of(context)?.trackMountainBreeze ?? 'Mountain Breeze',
        artist: AppLocalizations.of(context)?.artistNewAgeZen ?? 'New Age Zen',
        duration: const Duration(minutes: 6, seconds: 45),
        albumArt: '🏔️',
        color: const Color(0xFF95E1D3),
        audioPath: 'audio/music/mountain_breeze.mp3',
      ),
      MusicTrack(
        title: AppLocalizations.of(context)?.trackInnerPeace ?? 'Inner Peace',
        artist: AppLocalizations.of(context)?.artistMeditationSounds ?? 'Meditation Sounds',
        duration: const Duration(minutes: 8, seconds: 12),
        albumArt: '🧘',
        color: const Color(0xFFFFA07A),
        audioPath: 'audio/music/inner_peace.mp3',
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAnimations();
    _setupAudioPlayer();
  }

  void _setupAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });

        if (state == PlayerState.playing) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
        }
      }
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        _nextTrack();
      }
    });
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        final currentTrack = _getTracks(context)[_currentTrackIndex];
        if (currentTrack.audioPath != null) {
          await _audioPlayer.play(AssetSource(currentTrack.audioPath!));
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Audio file not found'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _previousTrack() async {
    await _audioPlayer.stop();
    setState(() {
      _currentTrackIndex = (_currentTrackIndex - 1 + _trackCount) % _trackCount;
      _position = Duration.zero;
    });

    if (_isPlaying) {
      await _togglePlayPause();
    }
  }

  Future<void> _nextTrack() async {
    await _audioPlayer.stop();
    setState(() {
      _currentTrackIndex = (_currentTrackIndex + 1) % _trackCount;
      _position = Duration.zero;
    });

    if (_isPlaying) {
      await _togglePlayPause();
    }
  }

  Future<void> _seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTrack = _getTracks(context)[_currentTrackIndex];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAlbumArtSection(theme, currentTrack),
            const SizedBox(height: 24),
            _buildTrackInfo(theme, currentTrack),
            const SizedBox(height: 20),
            _buildTrackIndicators(theme),
            const SizedBox(height: 40),
            _buildProgressSection(theme),
            const SizedBox(height: 40),
            _buildControlButtons(theme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumArtSection(ThemeData theme, MusicTrack track) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated waves
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: track.color.withValues(alpha: 0.2 + (_waveController.value * 0.1)),
                  width: 2,
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: track.color.withValues(alpha: 0.3 + (_waveController.value * 0.15)),
                  width: 2,
                ),
              ),
            );
          },
        ),
        // Album art with rotation and pulse
        AnimatedBuilder(
          animation: Listenable.merge([_rotationController, _pulseController]),
          builder: (context, child) {
            final pulseValue = _isPlaying ? 1.0 + (_pulseController.value * 0.05) : 1.0;
            return Transform.scale(
              scale: pulseValue,
              child: Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        track.color.withValues(alpha: 0.9),
                        track.color.withValues(alpha: 0.6),
                        track.color.withValues(alpha: 0.3),
                      ],
                      stops: const [0.3, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: track.color.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      track.albumArt,
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrackInfo(ThemeData theme, MusicTrack track) {
    return Column(
      children: [
        Text(
          track.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: track.color.withValues(alpha:0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            track.artist,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackIndicators(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _trackCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentTrackIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentTrackIndex
                ? _getTracks(context)[_currentTrackIndex].color
                : theme.colorScheme.outline.withValues(alpha:0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(ThemeData theme) {
    final currentTrack = _getTracks(context)[_currentTrackIndex];
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: currentTrack.color,
            inactiveTrackColor: theme.colorScheme.outline.withValues(alpha:0.2),
            thumbColor: currentTrack.color,
            overlayColor: currentTrack.color.withValues(alpha:0.2),
          ),
          child: Slider(
            value: _position.inSeconds.toDouble(),
            max: _duration.inSeconds.toDouble() > 0
                ? _duration.inSeconds.toDouble()
                : 1.0,
            onChanged: (value) {
              _seekTo(Duration(seconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons(ThemeData theme) {
    final currentTrack = _getTracks(context)[_currentTrackIndex];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            icon: Icons.skip_previous_rounded,
            onPressed: _previousTrack,
            size: 36,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 16),
          _buildPlayPauseButton(currentTrack.color),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: Icons.skip_next_rounded,
            onPressed: _nextTrack,
            size: 36,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton(Color color) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha:0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha:0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _togglePlayPause,
          customBorder: const CircleBorder(),
          child: Icon(
            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
    required Color color,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: size,
      color: color,
      padding: const EdgeInsets.all(12),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class MusicTrack {
  final String title;
  final String artist;
  final Duration duration;
  final String albumArt;
  final Color color;
  final String? audioPath;

  MusicTrack({
    required this.title,
    required this.artist,
    required this.duration,
    required this.albumArt,
    required this.color,
    this.audioPath,
  });
}
