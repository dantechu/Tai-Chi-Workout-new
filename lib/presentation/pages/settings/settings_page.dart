import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_event.dart';
import '../../bloc/theme/theme_state.dart';
import '../../bloc/locale/locale_bloc.dart';
import '../../bloc/locale/locale_event.dart';
import '../../bloc/locale/locale_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.settings ?? 'Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPremiumTile(context),
          const SizedBox(height: 8),
          _buildCoursesSection(context),
          const SizedBox(height: 8),
          _buildAppearanceSection(context),
          const SizedBox(height: 8),
          _buildLanguageSection(context),
          const SizedBox(height: 8),
          _buildAboutSection(context),
          const SizedBox(height: 8),
          _buildSupportSection(context),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)?.appearance ?? 'Appearance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return Column(
                  children: [
                    RadioListTile<AppThemeMode>(
                      title: Text(AppLocalizations.of(context)?.light ?? 'Light'),
                      subtitle: Text(AppLocalizations.of(context)?.lightThemeDescription ?? 'Always use light theme'),
                      value: AppThemeMode.light,
                      groupValue: state.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          context.read<ThemeBloc>().add(ChangeTheme(value));
                        }
                      },
                    ),
                    RadioListTile<AppThemeMode>(
                      title: Text(AppLocalizations.of(context)?.dark ?? 'Dark'),
                      subtitle: Text(AppLocalizations.of(context)?.darkThemeDescription ?? 'Always use dark theme'),
                      value: AppThemeMode.dark,
                      groupValue: state.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          context.read<ThemeBloc>().add(ChangeTheme(value));
                        }
                      },
                    ),
                    RadioListTile<AppThemeMode>(
                      title: Text(AppLocalizations.of(context)?.system ?? 'System'),
                      subtitle: Text(AppLocalizations.of(context)?.systemThemeDescription ?? 'Follow system setting'),
                      value: AppThemeMode.system,
                      groupValue: state.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          context.read<ThemeBloc>().add(ChangeTheme(value));
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)?.language ?? 'Language',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<LocaleBloc, LocaleState>(
              builder: (context, state) {
                return Column(
                  children: AppConstants.supportedLocales.map((language) {
                    final locale = Locale(language['code'] as String);
                    final isSelected = state.locale.languageCode == locale.languageCode;
                    
                    return ListTile(
                      leading: Text(
                        language['flag'] as String,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(language['name'] as String),
                      trailing: isSelected 
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        context.read<LocaleBloc>().add(ChangeLocale(locale));
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)?.about ?? 'About',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCompactListItem(
              context,
              icon: Icons.person,
              title: AppLocalizations.of(context)?.instructor ?? 'Instructor',
              subtitle: AppLocalizations.of(context)?.johnSaxxon ?? 'John Saxxon',
              onTap: () => _showInstructorDialog(context),
            ),
            _buildCompactListItem(
              context,
              icon: Icons.info_outline,
              title: AppLocalizations.of(context)?.version ?? 'App Version',
              subtitle: '${AppConstants.appVersion} (${AppConstants.bundleId})',
            ),
            _buildCompactListItem(
              context,
              icon: Icons.star_rate,
              title: AppLocalizations.of(context)?.rateApp ?? 'Rate App',
              onTap: () => _showRatingDialog(context),
              showTrailing: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.support,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)?.support ?? 'Support',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCompactListItem(
              context,
              icon: Icons.email,
              title: AppLocalizations.of(context)?.contactUs ?? 'Contact Support',
              subtitle: AppConstants.supportEmail,
              onTap: () => _launchEmail(AppConstants.supportEmail),
              showTrailing: true,
            ),
            _buildCompactListItem(
              context,
              icon: Icons.phone,
              title: AppLocalizations.of(context)?.support ?? 'Phone Support',
              subtitle: AppConstants.supportPhone,
              onTap: () => _launchPhone(AppConstants.supportPhone),
              showTrailing: true,
            ),
            _buildCompactListItem(
              context,
              icon: Icons.web,
              title: AppLocalizations.of(context)?.website ?? 'Website',
              subtitle: AppConstants.website,
              onTap: () => _launchUrl('https://${AppConstants.website}'),
              showTrailing: true,
            ),
            _buildCompactListItem(
              context,
              icon: Icons.privacy_tip,
              title: AppLocalizations.of(context)?.privacyPolicy ?? 'Privacy Policy',
              onTap: () => _launchUrl(AppConstants.privacyPolicyUrl),
              showTrailing: true,
            ),
            _buildCompactListItem(
              context,
              icon: Icons.description,
              title: AppLocalizations.of(context)?.termsOfService ?? 'Terms of Service',
              onTap: () => _launchUrl(AppConstants.termsOfServiceUrl),
              showTrailing: true,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactListItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool showTrailing = false,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showTrailing && onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInstructorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.aboutJohnSaxxon ?? 'About John Saxxon'),
        content: Text(
          AppLocalizations.of(context)?.johnSaxxonBio ?? 
          'John Saxxon is a certified Tai Chi instructor with over 20 years of experience. '
          'He has trained thousands of students worldwide in the art of Tai Chi and meditation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.close ?? 'Close'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.rateOurApp ?? 'Rate Our App'),
        content: Text(
          AppLocalizations.of(context)?.rateAppMessage ?? 
          'If you enjoy using our Tai Chi app, please take a moment to rate it. '
          'Your feedback helps us improve the app for everyone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.later ?? 'Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, this would open the app store
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)?.thankYouRating ?? 'Thank you! Opening app store...'),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)?.rateNow ?? 'Rate Now'),
          ),
        ],
      ),
    );
  }

  void _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email?subject=Tai Chi App Support');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildPremiumTile(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 8,
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/premium');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.diamond,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.premiumTitle ?? 'Unlock Premium',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)?.premiumSubtitle ?? 'Get unlimited access to all features',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/courses');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Courses',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose your learning path',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}