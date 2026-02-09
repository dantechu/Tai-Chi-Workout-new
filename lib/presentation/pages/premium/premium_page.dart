import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';
import '../../bloc/premium/premium_bloc.dart';
import '../../bloc/premium/premium_event.dart';
import '../../bloc/premium/premium_state.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.premium ?? 'Premium'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        surfaceTintColor: theme.colorScheme.surface,
        systemOverlayStyle: theme.brightness == Brightness.light
            ? const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              )
            : const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
      ),
      body: BlocConsumer<PremiumBloc, PremiumState>(
        listener: (context, state) {
          if (state is PremiumPurchaseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)?.premiumThankYou ?? 
                    'Thank you for your support!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is PremiumError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PremiumActive) {
            return _buildActiveContent(context, theme);
          }
          
          return _buildPremiumContent(context, theme, state);
        },
      ),
    );
  }

  Widget _buildActiveContent(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.stars_rounded,
            size: 80,
            color: Colors.amber,
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)?.premiumActive ?? 'Premium Active',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)?.premiumThankYou ??
                'Thank you for your support!',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumContent(BuildContext context, ThemeData theme, PremiumState state) {
    return Column(
      children: [
        _buildCompactHeader(theme),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildCompactFeatures(theme),
                const Spacer(),
                _buildPricing(theme, state),
                const SizedBox(height: 20),
                _buildButtons(theme, state),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.diamond_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)?.premiumTitle ?? 'Unlock Premium',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.premiumSubtitle ??
                'Enjoy an ad-free experience with premium support',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildCompactFeatures(ThemeData theme) {
    final features = [
      {'icon': Icons.download_for_offline_outlined, 'title': AppLocalizations.of(context)?.premiumFeature1 ?? 'Offline downloads'},
      {'icon': Icons.block_outlined, 'title': AppLocalizations.of(context)?.premiumFeature2 ?? 'No advertisements'},
      {'icon': Icons.support_agent_outlined, 'title': AppLocalizations.of(context)?.premiumFeature4 ?? 'Priority support'},
    ];

    return Column(
      children: features.map((feature) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  feature['title'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.check_circle_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  Widget _buildPricing(ThemeData theme, PremiumState state) {
    String displayPrice = '\$1.99';

    // Get the price from the state if available
    if (state is PremiumInactive && state.productPrice != null) {
      displayPrice = state.productPrice!;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Lifetime Access',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 17,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayPrice,
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: 48,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'One-time payment',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(ThemeData theme, PremiumState state) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: state is PremiumLoading
                ? null
                : () {
                    context.read<PremiumBloc>().add(const PurchasePremiumRequested());
                  },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: state is PremiumLoading
                ? const SizedBox.shrink()
                : const Icon(Icons.shopping_cart_outlined, size: 18),
            label: state is PremiumLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    AppLocalizations.of(context)?.purchase ?? 'Purchase Premium',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            context.read<PremiumBloc>().add(const RestorePremiumRequested());
          },
          icon: Icon(
            Icons.restore_outlined,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          label: Text(
            AppLocalizations.of(context)?.restore ?? 'Restore Purchases',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}