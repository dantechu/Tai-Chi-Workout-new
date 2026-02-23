import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'music_player_page.dart';
import '../breathing/breathing_timer_page.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  // Define gradients for each tab
  final _musicGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B6B),
      Color(0x00FF6B6B),
    ],
    stops: [0.0, 0.3],
  );

  final _breathingGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x266B73FF), // #6B73FF with 15% opacity
      Colors.transparent,
    ],
    stops: [0.0, 0.5],
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index != _currentTabIndex) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Gradient _getCurrentGradient() {
    switch (_currentTabIndex) {
      case 0:
        return _musicGradient;
      case 1:
        return _breathingGradient;
      default:
        return _musicGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _getCurrentGradient(),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                elevation: 0,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: theme.colorScheme.primary,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.music_note),
                      text: AppLocalizations.of(context)?.music ?? 'Music',
                    ),
                    Tab(
                      icon: const Icon(Icons.air),
                      text: AppLocalizations.of(context)?.breathing ?? 'Breathing',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    MusicPlayerPage(),
                    BreathingTimerPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
