import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import '../../../core/utils/localization_helper.dart';
import '../../../domain/entities/course.dart';
import '../../../l10n/app_localizations.dart';

/// Page for viewing and downloading the certificate.
///
/// Features:
/// - Displays certificate template with user's name overlaid in center
/// - Uses elegant cursive font for the name
/// - Download button to save to gallery
class CertificateViewPage extends StatefulWidget {
  final Course course;
  final String userName;

  const CertificateViewPage({
    super.key,
    required this.course,
    required this.userName,
  });

  @override
  State<CertificateViewPage> createState() => _CertificateViewPageState();
}

class _CertificateViewPageState extends State<CertificateViewPage> {
  final GlobalKey _certificateKey = GlobalKey();
  bool _isDownloading = false;
  bool _isImageLoaded = false;

  Future<void> _downloadCertificate() async {
    if (_isDownloading) return;

    setState(() => _isDownloading = true);

    try {
      // Request storage permission
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        // Try storage permission for older Android
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          if (mounted) {
            _showSnackBar(
              AppLocalizations.of(context)?.storagePermissionRequired ??
                  'Storage permission is required to save the certificate',
              isError: true,
            );
          }
          setState(() => _isDownloading = false);
          return;
        }
      }

      // Capture the certificate widget as image
      final boundary = _certificateKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        _showSnackBar(
          AppLocalizations.of(context)?.errorGeneratingCertificate ??
              'Error generating certificate',
          isError: true,
        );
        setState(() => _isDownloading = false);
        return;
      }

      // Capture at higher resolution for quality
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _showSnackBar(
          AppLocalizations.of(context)?.errorGeneratingCertificate ??
              'Error generating certificate',
          isError: true,
        );
        setState(() => _isDownloading = false);
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();

      // Save to gallery
      final result = await SaverGallery.saveImage(
        pngBytes,
        quality: 100,
        name: 'certificate_${widget.course.id}_${DateTime.now().millisecondsSinceEpoch}.png',
        androidRelativePath: 'Pictures/Certificates',
        androidExistNotSave: false,
      );

      if (mounted) {
        if (result.isSuccess) {
          _showSnackBar(
            AppLocalizations.of(context)?.certificateSaved ??
                'Certificate saved to gallery!',
          );
        } else {
          _showSnackBar(
            AppLocalizations.of(context)?.errorSavingCertificate ??
                'Error saving certificate',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          '${AppLocalizations.of(context)?.error ?? 'Error'}: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);
    final courseName = widget.course.getLocalizedName(langCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.certificate ?? 'Certificate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Certificate preview
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: RepaintBoundary(
                  key: _certificateKey,
                  child: _buildCertificate(theme, courseName),
                ),
              ),
            ),
          ),

          // Download button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: (_isDownloading || !_isImageLoaded)
                      ? null
                      : _downloadCertificate,
                  icon: _isDownloading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.download_rounded),
                  label: Text(
                    _isDownloading
                        ? (l10n?.saving ?? 'Saving...')
                        : (l10n?.downloadCertificate ?? 'Download Certificate'),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificate(ThemeData theme, String courseName) {
    final certificateUrl = widget.course.certificateImageUrl;

    if (certificateUrl == null || certificateUrl.isEmpty) {
      return _buildErrorState(theme);
    }

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 600,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Certificate background image
            CachedNetworkImage(
              imageUrl: certificateUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => AspectRatio(
                aspectRatio: 1.414, // A4 landscape ratio
                child: Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => _buildErrorState(theme),
              imageBuilder: (context, imageProvider) {
                // Mark image as loaded
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_isImageLoaded) {
                    setState(() => _isImageLoaded = true);
                  }
                });

                return Image(
                  image: imageProvider,
                  fit: BoxFit.contain,
                );
              },
            ),

            // Name overlay - positioned in center
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    widget.userName,
                    style: GoogleFonts.greatVibes(
                      fontSize: 42,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    final l10n = AppLocalizations.of(context);

    return AspectRatio(
      aspectRatio: 1.414,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.certificateNotAvailable ?? 'Certificate not available',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
