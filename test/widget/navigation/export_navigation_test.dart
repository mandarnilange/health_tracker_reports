import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:hive/hive.dart';
import 'package:health_tracker_reports/presentation/pages/export/export_page.dart';
import 'package:health_tracker_reports/presentation/router/route_names.dart';

void main() {
  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('export_nav_test');
    Hive.init(tempDir.path);
    await configureDependencies();
  });

  testWidgets('export route renders export page', (tester) async {
    final router = GoRouter(
      initialLocation: RouteNames.export,
      routes: [
        GoRoute(
          path: RouteNames.export,
          name: RouteNames.exportName,
          builder: (context, state) => const ExportPage(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ExportPage), findsOneWidget);
  });
}
