import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection_container.dart' as di;
import '../../../l10n/app_localizations.dart';
import '../../bloc/video/video_bloc.dart';
import '../../bloc/video/video_event.dart';
import '../../bloc/premium/premium_bloc.dart';
import '../../bloc/statistics/statistics_bloc.dart';
import '../../bloc/statistics/statistics_event.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_event.dart';
import '../home/home_page.dart';
import '../../courses/pages/courses_page.dart';
import '../statistics/statistics_page.dart';
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
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: AppLocalizations.of(context)?.home ?? 'Home',
        page: const HomePage(),
      ),
      NavigationItem(
        icon: Icons.school_outlined,
        selectedIcon: Icons.school_rounded,
        label: AppLocalizations.of(context)?.courses ?? 'Courses',
        page: const CoursesPage(),
      ),
      NavigationItem(
        icon: Icons.analytics_outlined,
        selectedIcon: Icons.analytics_rounded,
        label: AppLocalizations.of(context)?.statisticsTab ?? 'Statistics',
        page: const StatisticsPage(),
      ),
      NavigationItem(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
        label: AppLocalizations.of(context)?.settings ?? 'Settings',
        page: const SettingsPage(),
      ),
    ];
  }


  void _onTabTapped(BuildContext blocContext, int index) {
    // Refresh data when switching tabs
    if (index == 0) {
      // Home tab: reload selected course and videos
      blocContext.read<CoursesBloc>().add(const LoadSelectedCourse());
      blocContext.read<VideoBloc>().add(const LoadVideos());
    } else if (index == 1) {
      // Courses tab: ensure courses list is loaded
      blocContext.read<CoursesBloc>().add(const LoadCourses());
    } else if (index == 2) {
      // Statistics tab: refresh statistics
      blocContext.read<StatisticsBloc>().add(const RefreshStatistics());
    }
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
        BlocProvider<CoursesBloc>(
          create: (context) => di.sl<CoursesBloc>(),
        ),
        BlocProvider<StatisticsBloc>(
          create: (context) => di.sl<StatisticsBloc>(),
        ),
      ],
      child: Builder(
        builder: (blocContext) {
          // Determine status bar style based on theme brightness
          final brightness = Theme.of(blocContext).brightness;
          final systemUiOverlayStyle = brightness == Brightness.dark
              ? SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Theme.of(blocContext).colorScheme.surface,
                )
              : SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Theme.of(blocContext).colorScheme.surface,
                );

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: systemUiOverlayStyle,
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
              bottomNavigationBar: _buildBottomNavigationBar(blocContext, navigationItems),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext blocContext, List<NavigationItem> navigationItems) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Row(
            children: navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTabTapped(blocContext, index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isSelected ? item.selectedIcon : item.icon,
                          size: 22,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget page;

  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.page,
  });
}
