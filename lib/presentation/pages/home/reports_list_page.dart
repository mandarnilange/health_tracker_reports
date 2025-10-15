import 'package:flutter/material.dart';
export 'package:health_tracker_reports/core/error/failures.dart'
    show CacheFailure;
export 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart'
    show getAllReportsProvider, deleteReportProvider;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Reports'),
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
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const SizedBox.shrink()),
          );
        },
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
    final dateText = DateFormat.yMMMd().format(report.date);
    final biomarkerCount = report.totalBiomarkerCount;
    final outOfRangeCount = report.outOfRangeCount;

    return Dismissible(
      key: ValueKey(report.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Colors.red.shade700,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => _deleteReport(context, ref, report.id),
      child: ListTile(
        title: Text(report.labName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateText),
            Text('$biomarkerCount biomarker${biomarkerCount == 1 ? '' : 's'}'),
            Text('$outOfRangeCount out of range'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const SizedBox.shrink()),
          );
        },
      ),
    );
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
