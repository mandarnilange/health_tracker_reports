import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
import 'package:health_tracker_reports/presentation/providers/search_provider.dart';
import 'package:health_tracker_reports/presentation/providers/filter_provider.dart';
import 'package:health_tracker_reports/presentation/widgets/biomarker_card.dart';
import 'package:intl/intl.dart';

/// Report detail page that displays comprehensive information about a specific report.
///
/// This page shows all biomarkers, trends, and allows users to view
/// detailed analysis of a single health report.
class ReportDetailPage extends ConsumerWidget {
  /// The ID of the report to display
  final String reportId;

  const ReportDetailPage({
    super.key,
    required this.reportId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return reportsAsync.when(
      data: (reports) {
        // Find the specific report by ID
        final report = reports.cast<Report?>().firstWhere(
              (r) => r?.id == reportId,
              orElse: () => null,
            );

        if (report == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Report Details'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Report not found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The requested report could not be found.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(DateFormat('MMM dd, yyyy').format(report.date)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Lab name section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lab',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.labName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Out-of-range summary chip
              if (report.hasOutOfRangeBiomarkers)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${report.outOfRangeCount} out of ${report.totalBiomarkerCount} biomarkers out of range',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'All biomarkers within normal range',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Biomarkers section header with filter chip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Biomarkers',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  FilterChip(
                    label: const Text('Out of Range Only'),
                    selected: ref.watch(filterProvider) ==
                        BiomarkerFilter.outOfRangeOnly,
                    onSelected: (_) {
                      ref.read(filterProvider.notifier).toggleFilter();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Search bar
              TextField(
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).updateQuery(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search biomarkers...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: ref.watch(searchQueryProvider).isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            ref.read(searchQueryProvider.notifier).clearQuery();
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Biomarker cards with search and filter applied
              ...ref
                      .watch(searchedAndFilteredBiomarkersProvider(report))
                      .isEmpty
                  ? [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No biomarkers found',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filter',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]
                  : ref
                      .watch(searchedAndFilteredBiomarkersProvider(report))
                      .map(
                        (biomarker) => BiomarkerCard(biomarker: biomarker),
                      ),

              // Notes section
              if (report.notes != null && report.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notes',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.notes!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // TODO: Navigate to edit/review page with this report
              // Navigator.of(context).pushNamed('/review', arguments: report);
            },
            child: const Icon(Icons.edit),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Report Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) {
        String errorMessage = 'An error occurred';
        if (error is Failure) {
          errorMessage = error.message;
        } else {
          errorMessage = error.toString();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Report Details'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(reportsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
