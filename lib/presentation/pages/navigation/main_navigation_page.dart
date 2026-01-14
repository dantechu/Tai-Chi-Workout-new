import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection_container.dart' as di;
import '../../../l10n/app_localizations.dart';
import '../../bloc/video/video_bloc.dart';
import '../../bloc/premium/premium_bloc.dart';
import '../home/home_page.dart';
import '../practice/practice_page.dart';
import '../breathing/breathing_timer_page.dart';
import '../settings/settings_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  List<NavigationItem> _getNavigationItems(BuildContext context) {
    return [
      NavigationItem(
        icon: Icons.home,
        label: AppLocalizations.of(context)?.home ?? 'Home',
        page: const HomePage(),
      ),
      NavigationItem(
        icon: Icons.self_improvement,
        label: AppLocalizations.of(context)?.practice ?? 'Practice',
        page: const PracticePage(),
      ),
      NavigationItem(
        icon: Icons.air,
        label: AppLocalizations.of(context)?.breathingTimer ?? 'Breathing Timer',
        page: const BreathingTimerPage(),
      ),
      NavigationItem(
        icon: Icons.settings,
        label: AppLocalizations.of(context)?.settings ?? 'Settings',
        page: const SettingsPage(),
      ),
    ];
  }


  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationItems = _getNavigationItems(context);
    
    return MultiBlocProvider(
      providers: [
        BlocProvider<VideoBloc>(
          create: (context) => di.sl<VideoBloc>(),
        ),
        BlocProvider<PremiumBloc>(
          create: (context) => di.sl<PremiumBloc>(),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: navigationItems.asMap().entries.map((entry) {
            return KeyedSubtree(
              key: ValueKey('page_${entry.key}'),
              child: entry.value.page,
            );
          }).toList(),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(navigationItems),
      ),
    );
  }

  Widget _buildBottomNavigationBar(List<NavigationItem> navigationItems) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.labelSmall,
        elevation: 0,
        items: navigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Icon(
                item.icon,
                size: 24,
              ),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Icon(
                  item.icon,
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Widget page;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.page,
  });
}