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
            Icons.star,
            size: 120,
            color: Colors.amber,
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)?.premiumActive ?? 'Premium Active',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)?.premiumThankYou ?? 
                'Thank you for your support!',
            style: theme.textTheme.bodyLarge?.copyWith(
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildCompactFeatures(theme),
                const Spacer(),
                _buildPricing(theme, state),
                const SizedBox(height: 16),
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: Column(
        children: [
          Icon(
            Icons.diamond,
            size: 60,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)?.premiumTitle ?? 'Unlock Premium',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)?.premiumSubtitle ??
                'Enjoy an ad-free experience with premium support',
            style: theme.textTheme.bodyMedium?.copyWith(
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
      {'icon': Icons.download_for_offline, 'title': AppLocalizations.of(context)?.premiumFeature1 ?? 'Offline downloads'},
      {'icon': Icons.block, 'title': AppLocalizations.of(context)?.premiumFeature2 ?? 'No advertisements'},
      {'icon': Icons.support_agent, 'title': AppLocalizations.of(context)?.premiumFeature4 ?? 'Priority support'},
    ];

    return Column(
      children: features.map((feature) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feature['title'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.check,
                color: theme.colorScheme.primary,
                size: 18,
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
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Lifetime Access',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayPrice,
            style: theme.textTheme.displayMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'One-time payment',
            style: theme.textTheme.bodyMedium?.copyWith(
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
          child: FilledButton(
            onPressed: state is PremiumLoading
                ? null
                : () {
                    context.read<PremiumBloc>().add(const PurchasePremiumRequested());
                  },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: state is PremiumLoading
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () {
            context.read<PremiumBloc>().add(const RestorePremiumRequested());
          },
          child: Text(
            AppLocalizations.of(context)?.restore ?? 'Restore Purchases',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}