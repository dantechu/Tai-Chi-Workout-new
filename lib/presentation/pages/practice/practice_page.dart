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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Material(
              color: theme.colorScheme.surface,
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
    );
  }
}
