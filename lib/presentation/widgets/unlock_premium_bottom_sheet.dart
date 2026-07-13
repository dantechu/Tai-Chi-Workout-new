import 'package:flutter/material.dart';
import '../../core/services/ad_unlock_service.dart';
import '../../core/services/rewarded_ad_service.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/section.dart';
import '../../l10n/app_localizations.dart';
import '../pages/lessons/lesson_router.dart';

/// Bottom sheet shown when a free user tries to access a premium lesson.
///
/// Offers two options:
/// 1. Watch a rewarded ad to unlock the lesson (with daily limit)
/// 2. Upgrade to premium for unlimited access
class UnlockPremiumBottomSheet extends StatefulWidget {
  final Video lesson;
  final List<Section>? sections;

  const UnlockPremiumBottomSheet({
    super.key,
    required this.lesson,
    this.sections,
  });

  /// Show the bottom sheet and handle the unlock flow.
  ///
  /// Returns true if the lesson was unlocked, false otherwise.
  static Future<bool> show({
    required BuildContext context,
    required Video lesson,
    List<Section>? sections,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UnlockPremiumBottomSheet(
        lesson: lesson,
        sections: sections,
      ),
    );
    return result ?? false;
  }

  @override
  State<UnlockPremiumBottomSheet> createState() => _UnlockPremiumBottomSheetState();
}

class _UnlockPremiumBottomSheetState extends State<UnlockPremiumBottomSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final adUnlockService = AdUnlockService();
    final canUnlockMore = adUnlockService.canUnlockMore();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Premium icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade400,
                      Colors.orange.shade500,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                l10n?.premiumLesson ?? 'Premium Lesson',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                l10n?.unlockToAccess ?? 'Unlock this lesson to continue learning',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Watch Ad Button
              if (canUnlockMore) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onWatchAdPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_circle_outline_rounded, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                l10n?.watchAdToUnlock ?? 'Watch Ad to Unlock',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Divider with "or"
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n?.or ?? 'or',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Daily limit reached message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.orange.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n?.dailyLimitReached ?? 'Daily free unlock limit reached. Upgrade to Pro for unlimited access!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Upgrade to Pro Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _onUpgradePressed,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 24,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n?.upgradeToPro ?? 'Upgrade to Pro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel button
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  l10n?.cancel ?? 'Cancel',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onWatchAdPressed() {
    setState(() => _isLoading = true);

    final rewardedAdService = RewardedAdService();
    final navigator = Navigator.of(context);

    final shown = rewardedAdService.showAd(
      onRewarded: () async {
        // User watched the full ad - unlock the lesson
        final unlocked = await AdUnlockService().unlockLesson(widget.lesson.id);
        if (unlocked && mounted) {
          // Close bottom sheet and navigate to lesson
          navigator.pop(true);
          LessonRouter.navigateToLesson(
            navigator.context,
            widget.lesson,
            sections: widget.sections,
          );
        }
      },
      onAdDismissed: () {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
      onAdFailedToShow: () {
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorSnackbar();
        }
      },
    );

    if (!shown) {
      setState(() => _isLoading = false);
      _showErrorSnackbar();
    }
  }

  void _showErrorSnackbar() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.adNotReady ?? 'Ad not ready. Please try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onUpgradePressed() {
    Navigator.pop(context, false);
    Navigator.pushNamed(context, '/premium');
  }
}
