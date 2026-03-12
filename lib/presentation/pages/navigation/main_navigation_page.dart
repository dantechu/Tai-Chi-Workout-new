import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection_container.dart' as di;
import '../../../l10n/app_localizations.dart';
import '../../bloc/video/video_bloc.dart';
import '../../bloc/video/video_event.dart';
import '../../bloc/premium/premium_bloc.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_event.dart';
import '../home/home_page.dart';
import '../practice/practice_page.dart';
import '../../courses/pages/courses_page.dart';
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
        icon: Icons.school,
        label: AppLocalizations.of(context)?.courses ?? 'Courses',
        page: const CoursesPage(),
      ),
      NavigationItem(
        icon: Icons.settings,
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
    } else if (index == 2) {
      // Courses tab: ensure courses list is loaded
      blocContext.read<CoursesBloc>().add(const LoadCourses());
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
        onTap: (index) => _onTabTapped(blocContext, index),
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