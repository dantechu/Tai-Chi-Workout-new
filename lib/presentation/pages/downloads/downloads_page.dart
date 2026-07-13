import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/entities/download_item.dart';
import '../../../domain/usecases/download_usecases.dart';
import '../../../injection_container.dart';
import '../../../l10n/app_localizations.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  List<DownloadItem> _downloads = [];
  bool _isLoading = true;
  String? _error;
  int _totalStorageUsed = 0;
  final Map<String, int> _actualFileSizes = {};

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final getAllDownloads = sl<GetAllDownloads>();
      final result = await getAllDownloads();

      result.fold(
        (failure) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        },
        (downloads) async {
          // Calculate total storage used and get actual file sizes
          int totalBytes = 0;
          final fileSizes = <String, int>{};
          for (final download in downloads) {
            if (download.isCompleted) {
              final file = File(download.localPath);
              if (await file.exists()) {
                final fileSize = await file.length();
                totalBytes += fileSize;
                fileSizes[download.id] = fileSize;
              }
            }
          }

          setState(() {
            _downloads = downloads;
            _totalStorageUsed = totalBytes;
            _actualFileSizes.clear();
            _actualFileSizes.addAll(fileSizes);
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDownload(DownloadItem download) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.delete ?? 'Delete Download'),
        content: const Text('Are you sure you want to delete this download?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final deleteDownload = sl<DeleteDownload>();
      final result = await deleteDownload(download.id);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Download deleted'),
                backgroundColor: Colors.green,
              ),
            );
            _loadDownloads();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAllDownloads() async {
    if (_downloads.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Downloads'),
        content: const Text('Are you sure you want to delete all downloaded content? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final deleteDownload = sl<DeleteDownload>();
      int deletedCount = 0;

      for (final download in _downloads) {
        final result = await deleteDownload(download.id);
        result.fold(
          (failure) {},
          (_) => deletedCount++,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted $deletedCount downloads'),
            backgroundColor: Colors.green,
          ),
        );
        _loadDownloads();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
            : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
        title: const Text(
          'Downloads',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          if (_downloads.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _deleteAllDownloads,
              tooltip: 'Delete All',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _loadDownloads,
                        icon: const Icon(Icons.refresh),
                        label: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDownloads,
                  child: CustomScrollView(
                    slivers: [
                      // Storage info card
                      SliverToBoxAdapter(
                        child: _buildStorageCard(context),
                      ),
                      // Downloads list
                      if (_downloads.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.download_done_rounded,
                                  size: 64,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No downloads yet',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Download videos and audio for offline access',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildDownloadItem(context, _downloads[index]),
                              childCount: _downloads.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStorageCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final completedCount = _downloads.where((d) => d.isCompleted).length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.12),
            theme.colorScheme.primary.withValues(alpha: isDark ? 0.1 : 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.storage_rounded,
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
                  'Storage Used',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatFileSize(_totalStorageUsed)} ($completedCount items)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadItem(BuildContext context, DownloadItem download) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    IconData statusIcon;
    Color statusColor;
    String statusText;

    switch (download.status) {
      case DownloadStatus.completed:
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusText = 'Downloaded';
      case DownloadStatus.downloading:
        statusIcon = Icons.downloading;
        statusColor = Colors.blue;
        statusText = '${(download.progress * 100).toInt()}%';
      case DownloadStatus.paused:
        statusIcon = Icons.pause_circle;
        statusColor = Colors.orange;
        statusText = 'Paused';
      case DownloadStatus.failed:
        statusIcon = Icons.error;
        statusColor = Colors.red;
        statusText = 'Failed';
      case DownloadStatus.cancelled:
        statusIcon = Icons.cancel;
        statusColor = Colors.grey;
        statusText = 'Cancelled';
      case DownloadStatus.pending:
        statusIcon = Icons.pending;
        statusColor = Colors.grey;
        statusText = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        download.title ?? 'Unknown Lesson',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            statusIcon,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (download.isCompleted) ...[
                            const SizedBox(width: 12),
                            Text(
                              _formatFileSize(_actualFileSizes[download.id] ?? download.totalBytes),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Progress bar for downloading
                      if (download.isDownloading) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: download.progress,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Delete button
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: () => _deleteDownload(download),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
