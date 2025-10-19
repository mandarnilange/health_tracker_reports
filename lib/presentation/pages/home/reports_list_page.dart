import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/presentation/router/route_names.dart';
import 'package:health_tracker_reports/presentation/widgets/health_timeline.dart';

class ReportsListPage extends ConsumerWidget {
  const ReportsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Timeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.push(RouteNames.settings),
          ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: 'View Trends',
            onPressed: () => context.push(RouteNames.trends),
          ),
        ],
      ),
      body: const HealthTimeline(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.upload),
        tooltip: 'Upload Lab Report',
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}
