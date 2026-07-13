import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/offline_service.dart';

/// A widget that displays a banner when the app is offline.
///
/// Usage:
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       const OfflineBanner(),
///       Expanded(child: YourContent()),
///     ],
///   ),
/// )
/// ```
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  StreamSubscription<bool>? _subscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Get initial state
    _isOffline = OfflineService().isOffline;
    if (_isOffline) {
      _controller.value = 1.0;
    }

    // Listen for changes
    _subscription = OfflineService().offlineStream.listen((isOffline) {
      if (mounted) {
        setState(() {
          _isOffline = isOffline;
        });
        if (isOffline) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _heightAnimation,
      axisAlignment: -1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.shade700,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'You are offline',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '• Using cached content',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that wraps content and shows an offline banner at the top.
class OfflineAwareScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const OfflineAwareScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: body),
        ],
      ),
    );
  }
}
