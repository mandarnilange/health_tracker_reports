import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/presentation/providers/export_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:health_tracker_reports/data/datasources/external/share_service.dart';
import 'package:health_tracker_reports/presentation/providers/share_provider.dart';

class ExportPage extends ConsumerWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ExportState>(exportNotifierProvider, (previous, next) {
      if (previous?.status == next.status &&
          previous?.results == next.results &&
          previous?.failure == next.failure) {
        return;
      }

      if (next.status == ExportStatus.success && next.results.isNotEmpty) {
        final message = next.results
            .map((result) => 'Saved to: ${result.path}')
            .join('\n');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () async {
                final shareService = ref.read(shareServiceProvider);
                for (final result in next.results) {
                  await shareService.shareFile(XFile(result.path));
                }
              },
            ),
          ),
        );
      } else if (next.status == ExportStatus.error && next.failure != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.failure!.message)),
        );
      }
    });

    final exportState = ref.watch(exportNotifierProvider);
    final notifier = ref.read(exportNotifierProvider.notifier);
    final isBusy = exportState.status == ExportStatus.inProgress;
    final activeAction = exportState.activeAction;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _ExportButton(
              label: 'Export Reports CSV',
              icon: Icons.description_outlined,
              enabled: !isBusy,
              isLoading: isBusy && activeAction == ExportAction.reports,
              onPressed: notifier.exportReports,
            ),
            const SizedBox(height: 12),
            _ExportButton(
              label: 'Export Vitals CSV',
              icon: Icons.favorite_outline,
              enabled: !isBusy,
              isLoading: isBusy && activeAction == ExportAction.vitals,
              onPressed: notifier.exportVitals,
            ),
            const SizedBox(height: 12),
            _ExportButton(
              label: 'Export Trends CSV',
              icon: Icons.show_chart,
              enabled: !isBusy,
              isLoading: isBusy && activeAction == ExportAction.trends,
              onPressed: notifier.exportTrends,
            ),
            const SizedBox(height: 24),
            _ExportButton.filled(
              label: 'Export All CSVs',
              icon: Icons.cloud_download_outlined,
              enabled: !isBusy,
              isLoading: isBusy && activeAction == ExportAction.all,
              onPressed: notifier.exportAll,
            ),
            const SizedBox(height: 24),
            if (isBusy) _ProgressIndicator(state: exportState),
          ],
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    bool isFilled = false,
  }) : _isFilled = isFilled;

  const _ExportButton.filled({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool enabled = true,
    bool isLoading = false,
  }) : this(
          label: label,
          icon: icon,
          onPressed: onPressed,
          enabled: enabled,
          isLoading: isLoading,
          isFilled: true,
        );

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;
  final bool isLoading;
  final bool _isFilled;

  @override
  Widget build(BuildContext context) {
    final indicatorColor = _isFilled
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.primary;

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            ),
          ),
          const SizedBox(width: 12),
        ] else ...[
          Icon(icon),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final effectiveOnPressed = enabled && !isLoading ? onPressed : null;

    if (_isFilled) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.state});

  final ExportState state;

  @override
  Widget build(BuildContext context) {
    final percent = (state.progress * 100).clamp(0, 100).round();
    final progressText = state.total > 0
        ? 'Exporting ${state.completed} of ${state.total} files ($percent%)…'
        : 'Preparing exports…';

    return Column(
      children: [
        CircularProgressIndicator(
          value: state.total > 0 ? state.progress.clamp(0, 1) : null,
        ),
        const SizedBox(height: 12),
        Text(progressText, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
