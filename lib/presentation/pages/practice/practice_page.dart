import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../l10n/app_localizations.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.music ?? 'Music'),
        centerTitle: true,
      ),
      body: const MusicPlayerPage(),
    );
  }
}

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _waveController;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  int _currentTrackIndex = 0;
  double _volume = 0.7;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 5);

  // Download FREE Public Domain music from archive.org:
  // 1. https://archive.org/download/freepd/Page2/Ambient%20J%20Thoughtful.mp3 -> peaceful_morning.mp3
  // 2. https://archive.org/download/freepd/Page2/Chill%20Deep.mp3 -> flowing_water.mp3
  // 3. https://archive.org/download/freepd/Page2/New%20Age%20A%20Weathered.mp3 -> mountain_breeze.mp3
  // 4. https://archive.org/download/freepd/Page2/Slow%20Ticking%20Clock.mp3 -> inner_peace.mp3
  // Save all files to: assets/audio/music/
  final List<MusicTrack> _tracks = [
    MusicTrack(
      title: 'Peaceful Morning',
      artist: 'Ambient Meditation',
      duration: const Duration(minutes: 5, seconds: 32),
      albumArt: '🌅',
      audioPath: 'audio/music/peaceful_morning.mp3',
    ),
    MusicTrack(
      title: 'Flowing Water',
      artist: 'Deep Relaxation',
      duration: const Duration(minutes: 7, seconds: 18),
      albumArt: '🌊',
      audioPath: 'audio/music/flowing_water.mp3',
    ),
    MusicTrack(
      title: 'Mountain Breeze',
      artist: 'New Age Zen',
      duration: const Duration(minutes: 6, seconds: 45),
      albumArt: '🏔️',
      audioPath: 'audio/music/mountain_breeze.mp3',
    ),
    MusicTrack(
      title: 'Inner Peace',
      artist: 'Meditation Sounds',
      duration: const Duration(minutes: 8, seconds: 12),
      albumArt: '🧘',
      audioPath: 'audio/music/inner_peace.mp3',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAnimations();
    _setupAudioPlayer();
  }

  void _setupAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  void _setupAudioPlayer() {
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });

        if (state == PlayerState.playing) {
          _rotationController.repeat();
          _waveController.repeat();
        } else {
          _rotationController.stop();
          _waveController.stop();
        }
      }
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((Duration position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    // Listen to completion
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        _nextTrack();
      }
    });

    // Set initial volume
    _audioPlayer.setVolume(_volume);
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        final currentTrack = _tracks[_currentTrackIndex];
        if (currentTrack.audioPath != null) {
          await _audioPlayer.play(AssetSource(currentTrack.audioPath!));
        } else {
          // Show message if no audio file is available
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Audio file not found. Please add MP3 files to assets/audio/music/'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _previousTrack() async {
    await _audioPlayer.stop();
    setState(() {
      _currentTrackIndex = (_currentTrackIndex - 1 + _tracks.length) % _tracks.length;
      _position = Duration.zero;
    });

    if (_isPlaying) {
      await _togglePlayPause();
    }
  }

  Future<void> _nextTrack() async {
    await _audioPlayer.stop();
    setState(() {
      _currentTrackIndex = (_currentTrackIndex + 1) % _tracks.length;
      _position = Duration.zero;
    });

    if (_isPlaying) {
      await _togglePlayPause();
    }
  }

  Future<void> _seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> _setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
    setState(() {
      _volume = volume;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _rotationController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTrack = _tracks[_currentTrackIndex];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildAlbumArt(theme, currentTrack),
            const SizedBox(height: 32),
            _buildTrackInfo(theme, currentTrack),
            const SizedBox(height: 24),
            _buildProgressBar(theme),
            const SizedBox(height: 32),
            _buildControlButtons(theme),
            const SizedBox(height: 24),
            _buildVolumeControl(theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumArt(ThemeData theme, MusicTrack track) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * 3.14159,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.8),
                  theme.colorScheme.primary.withOpacity(0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                track.albumArt,
                style: const TextStyle(fontSize: 64),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackInfo(ThemeData theme, MusicTrack track) {
    return Column(
      children: [
        Text(
          track.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          track.artist,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble() > 0
                  ? _duration.inSeconds.toDouble()
                  : 1.0,
              onChanged: (value) {
                _seekTo(Duration(seconds: value.toInt()));
              },
              activeColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _previousTrack,
          icon: const Icon(Icons.skip_previous),
          iconSize: 40,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 16),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: _togglePlayPause,
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            iconSize: 32,
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: _nextTrack,
          icon: const Icon(Icons.skip_next),
          iconSize: 40,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildVolumeControl(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Icon(
            Icons.volume_down,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
              ),
              child: Slider(
                value: _volume,
                onChanged: (value) {
                  _setVolume(value);
                },
                activeColor: theme.colorScheme.primary,
                inactiveColor: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
          ),
          Icon(
            Icons.volume_up,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
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
  final String? audioPath; // Path to audio file in assets

  MusicTrack({
    required this.title,
    required this.artist,
    required this.duration,
    required this.albumArt,
    this.audioPath,
  });
}