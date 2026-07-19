import 'package:flutter/material.dart';
import '../../../core/services/certificate_service.dart';
import '../../../domain/entities/course.dart';
import '../../../l10n/app_localizations.dart';
import 'certificate_view_page.dart';

/// Page for entering the user's name for certificate generation.
///
/// Features:
/// - Text field for name entry
/// - Warning chip about name being permanent
/// - Generate Certificate button
/// - Name is saved to SharedPreferences (one-time only)
class CertificateNamePage extends StatefulWidget {
  final Course course;

  const CertificateNamePage({
    super.key,
    required this.course,
  });

  @override
  State<CertificateNamePage> createState() => _CertificateNamePageState();
}

class _CertificateNamePageState extends State<CertificateNamePage> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _generateCertificate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final certificateService = CertificateService();

    // Save the name
    final saved = await certificateService.saveCertificateName(name);
    if (!saved) {
      // Name already exists, but we can still proceed
    }

    // Mark course as completed for certificate
    await certificateService.markCourseCompleted(widget.course.id);

    if (!mounted) return;

    setState(() => _isLoading = false);

    // Navigate to certificate view page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CertificateViewPage(
          course: widget.course,
          userName: name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.getCertificate ?? 'Get Certificate'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Trophy icon
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade400,
                        Colors.orange.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                ),

                // Title
                Text(
                  l10n?.enterYourName ?? 'Enter Your Name',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  l10n?.nameWillAppearOnCertificate ??
                      'This name will appear on your certificate',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Warning chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n?.nameCannotBeChanged ??
                              'Make sure you enter your name correctly. Wrong name cannot be changed later.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Name input field
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n?.fullName ?? 'Full Name',
                    hintText: l10n?.enterFullName ?? 'Enter your full name',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n?.pleaseEnterName ?? 'Please enter your name';
                    }
                    if (value.trim().length < 2) {
                      return l10n?.nameTooShort ?? 'Name is too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Generate Certificate button
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generateCertificate,
                    icon: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.verified_rounded),
                    label: Text(
                      l10n?.generateCertificate ?? 'Generate Certificate',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
