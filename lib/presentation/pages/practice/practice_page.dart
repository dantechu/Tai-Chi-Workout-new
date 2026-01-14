import 'package:flutter/material.dart';
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
  bool _isPlaying = false;
  int _currentTrackIndex = 0;
  double _volume = 0.7;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 5);

  final List<MusicTrack> _tracks = [
    MusicTrack(
      title: 'Peaceful Morning',
      artist: 'Tai Chi Masters',
      duration: const Duration(minutes: 5, seconds: 32),
      albumArt: '🌅',
    ),
    MusicTrack(
      title: 'Flowing Water',
      artist: 'Nature Sounds',
      duration: const Duration(minutes: 7, seconds: 18),
      albumArt: '🌊',
    ),
    MusicTrack(
      title: 'Mountain Breeze',
      artist: 'Meditation Music',
      duration: const Duration(minutes: 6, seconds: 45),
      albumArt: '🏔️',
    ),
    MusicTrack(
      title: 'Inner Peace',
      artist: 'Zen Collection',
      duration: const Duration(minutes: 8, seconds: 12),
      albumArt: '🧘',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _rotationController.repeat();
      _waveController.repeat();
    } else {
      _rotationController.stop();
      _waveController.stop();
    }
  }

  void _previousTrack() {
    setState(() {
      _currentTrackIndex = (_currentTrackIndex - 1 + _tracks.length) % _tracks.length;
      _position = Duration.zero;
      _duration = _tracks[_currentTrackIndex].duration;
    });
  }

  void _nextTrack() {
    setState(() {
      _currentTrackIndex = (_currentTrackIndex + 1) % _tracks.length;
      _position = Duration.zero;
      _duration = _tracks[_currentTrackIndex].duration;
    });
  }

  @override
  void dispose() {
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
            const Spacer(),
            _buildTrackList(theme),
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
              max: _duration.inSeconds.toDouble(),
              onChanged: (value) {
                setState(() {
                  _position = Duration(seconds: value.toInt());
                });
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
                  setState(() {
                    _volume = value;
                  });
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

  Widget _buildTrackList(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Playlist',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...List.generate(_tracks.length, (index) {
            final track = _tracks[index];
            final isCurrentTrack = index == _currentTrackIndex;
            
            return ListTile(
              leading: Text(
                track.albumArt,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                track.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isCurrentTrack ? theme.colorScheme.primary : null,
                  fontWeight: isCurrentTrack ? FontWeight.w600 : null,
                ),
              ),
              subtitle: Text(
                track.artist,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isCurrentTrack 
                      ? theme.colorScheme.primary.withOpacity(0.7)
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Text(
                _formatDuration(track.duration),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              onTap: () {
                setState(() {
                  _currentTrackIndex = index;
                  _position = Duration.zero;
                  _duration = track.duration;
                });
              },
              tileColor: isCurrentTrack 
                  ? theme.colorScheme.primary.withOpacity(0.1) 
                  : null,
            );
          }),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

class MusicTrack {
  final String title;
  final String artist;
  final Duration duration;
  final String albumArt;

  MusicTrack({
    required this.title,
    required this.artist,
    required this.duration,
    required this.albumArt,
  });
}