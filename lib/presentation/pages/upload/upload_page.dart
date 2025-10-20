import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/presentation/pages/upload/widgets/extraction_loading_widget.dart';
import 'package:health_tracker_reports/presentation/providers/extraction_provider.dart';
import 'package:health_tracker_reports/presentation/providers/file_picker_provider.dart';

/// Page that handles selecting a report file and triggering extraction.
class UploadPage extends ConsumerWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _listenForExtraction(context, ref);

    final extractionState = ref.watch(extractionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Report'),
        elevation: 2,
      ),
      body: extractionState.when(
        data: (_) => _buildInitialState(context, ref),
        loading: () => const ExtractionLoadingWidget(),
        error: (error, _) => _buildErrorState(context, ref, error),
      ),
    );
  }

  void _listenForExtraction(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<Report?>>(extractionProvider, (previous, next) {
      final previousReport = previous?.valueOrNull;
      final nextReport = next.valueOrNull;

      if (nextReport != null && nextReport != previousReport) {
        Future.microtask(() async {
          if (!context.mounted) return;
          await context.push('/review', extra: nextReport);
          if (context.mounted) {
            ref.read(extractionProvider.notifier).reset();
          }
        });
      }
    });
  }

  Widget _buildInitialState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 4,
          child: InkWell(
            onTap: () => _pickFile(context, ref),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.upload_file,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Blood Report',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a PDF or image file',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    Object error,
  ) {
    var errorMessage = 'An unexpected error occurred';
    if (error is Failure) {
      errorMessage = error.message;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _pickFile(context, ref),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
    try {
      final filePath =
          await ref.read(reportFilePickerProvider).pickReportPath();

      if (filePath != null) {
        await ref.read(extractionProvider.notifier).extractFromFile(filePath);
      }
    } on PlatformException catch (e) {
      if (_isUserCancelled(e)) {
        return;
      }
      _showFilePickerError(
        context,
        e.message != null ? 'Failed to pick file: ${e.message}' : 'Failed to pick file.',
      );
    } catch (e) {
      _showFilePickerError(context, 'Failed to pick file: $e');
    }
  }

  bool _isUserCancelled(PlatformException exception) {
    final code = exception.code.toLowerCase();
    if (code == 'aborted' || code == 'cancelled' || code == 'canceled') {
      return true;
    }
    final message = exception.message?.toLowerCase() ?? '';
    return message.contains('cancel');
  }

  void _showFilePickerError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
