import 'package:flutter/material.dart';
export 'package:health_tracker_reports/core/error/failures.dart'
    show CacheFailure;
export 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart'
    show getAllReportsProvider, deleteReportProvider;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart'
    show reportsProvider, ReportSortOption;
import 'package:health_tracker_reports/presentation/router/route_names.dart';
import 'package:intl/intl.dart';

/// Home page displaying the list of saved reports.
class ReportsListPage extends ConsumerStatefulWidget {
  const ReportsListPage({super.key});

  @override
  ConsumerState<ReportsListPage> createState() => _ReportsListPageState();
}

class _ReportsListPageState extends ConsumerState<ReportsListPage> {
  Timer? _initialLoadTimer;

  @override
  void initState() {
    super.initState();
    _initialLoadTimer = Timer(const Duration(milliseconds: 16), () {
      if (mounted) {
        ref.read(reportsProvider.notifier).loadReports();
      }
    });
  }

  @override
  void dispose() {
    _initialLoadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(reportsProvider);
    final currentSort = ref.watch(reportsProvider.notifier).currentSortOption;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: 'View Trends',
            onPressed: () => context.go(RouteNames.trends),
          ),
          PopupMenuButton<ReportSortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort reports',
            onSelected: (option) {
              ref.read(reportsProvider.notifier).setSortOption(option);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ReportSortOption.newestFirst,
                child: Row(
                  children: [
                    Icon(
                      currentSort == ReportSortOption.newestFirst
                          ? Icons.check
                          : null,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Newest First'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ReportSortOption.oldestFirst,
                child: Row(
                  children: [
                    Icon(
                      currentSort == ReportSortOption.oldestFirst
                          ? Icons.check
                          : null,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Oldest First'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ReportSortOption.mostOutOfRange,
                child: Row(
                  children: [
                    Icon(
                      currentSort == ReportSortOption.mostOutOfRange
                          ? Icons.check
                          : null,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Most Out of Range'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ReportSortOption.labName,
                child: Row(
                  children: [
                    Icon(
                      currentSort == ReportSortOption.labName
                          ? Icons.check
                          : null,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Lab Name (A-Z)'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: reportsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error is Failure ? error.message : error.toString(),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(reportsProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return _ReportListItem(report: report);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(RouteNames.upload),
        tooltip: 'Upload New Report',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ReportListItem extends ConsumerWidget {
  const _ReportListItem({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateText = DateFormat.yMMMd().format(report.date);
    final biomarkerCount = report.totalBiomarkerCount;
    final outOfRangeCount = report.outOfRangeCount;

    return Dismissible(
      key: ValueKey(report.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      confirmDismiss: (_) => _deleteReport(context, ref, report.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Card(
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.go(RouteNames.reportDetailWithId(report.id)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Report Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.description,
                      size: 32,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Report Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lab Name
                        Text(
                          report.labName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Date
                        Text(
                          dateText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Biomarker Info Row
                        Row(
                          children: [
                            // Total biomarkers
                            Icon(
                              Icons.science,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$biomarkerCount ${biomarkerCount == 1 ? 'test' : 'tests'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Out of range warning chip
                            if (outOfRangeCount > 0) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      size: 14,
                                      color: colorScheme.onErrorContainer,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$outOfRangeCount',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onErrorContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: colorScheme.onTertiaryContainer,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'All Normal',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onTertiaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Trailing Icons
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: colorScheme.error,
                        ),
                        onPressed: () async {
                          final confirmed =
                              await _showDeleteConfirmation(context);
                          if (confirmed && context.mounted) {
                            await _deleteReport(context, ref, report.id);
                          }
                        },
                        tooltip: 'Delete report',
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Report'),
            content: Text('Are you sure you want to delete ${report.labName}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _deleteReport(
    BuildContext context,
    WidgetRef ref,
    String reportId,
  ) async {
    final deleteReport = ref.read(deleteReportProvider);
    final result = await deleteReport(reportId);

    return result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${failure.message}')),
        );
        return false;
      },
      (_) {
        ref.read(reportsProvider.notifier).refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report deleted')),
        );
        return true;
      },
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(reportsProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No reports yet'),
                SizedBox(height: 8),
                Text('Add your first report to get started'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
