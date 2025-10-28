import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/domain/entities/health_entry.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/repositories/timeline_repository.dart';
import 'package:health_tracker_reports/domain/usecases/get_unified_timeline.dart';
import 'package:health_tracker_reports/presentation/router/app_router.dart';
import 'package:health_tracker_reports/presentation/router/route_names.dart';
import 'package:health_tracker_reports/presentation/providers/timeline_provider.dart';
import 'package:health_tracker_reports/presentation/pages/error/error_page.dart';

class _FakeHealthEntry implements HealthEntry {
  @override
  String get id => 'entry-1';

  @override
  bool get hasWarnings => false;

  @override
  HealthEntryType get entryType => HealthEntryType.labReport;

  @override
  String get displayTitle => 'Fake Entry';

  @override
  String get displaySubtitle => 'Fake Entry Details';

  @override
  DateTime get timestamp => DateTime(2025, 1, 1);
}

class _StubTimelineRepository implements TimelineRepository {
  _StubTimelineRepository(this._entries);

  final List<HealthEntry> _entries;

  @override
  Future<Either<Failure, List<HealthEntry>>> getUnifiedTimeline({
    DateTime? startDate,
    DateTime? endDate,
    HealthEntryType? filterType,
  }) async {
    return Right(_entries);
  }
}

class _FakeTimelineNotifier extends TimelineNotifier {
  _FakeTimelineNotifier()
      : super(
          getUnifiedTimeline: GetUnifiedTimeline(
            repository: _StubTimelineRepository([
              _FakeHealthEntry(),
            ]),
          ),
        );
}

void main() {
  Future<void> _pumpRouter(
    WidgetTester tester,
    GoRouter router,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          timelineProvider.overrideWith((ref) => _FakeTimelineNotifier()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('review route without report extra shows ErrorPage',
      (tester) async {
    final router = AppRouter.createRouter();
    await _pumpRouter(tester, router);

    router.go(RouteNames.review);
    await tester.pumpAndSettle();

    expect(find.byType(ErrorPage), findsOneWidget);
  });

  testWidgets('report detail route without id shows ErrorPage',
      (tester) async {
    final router = AppRouter.createRouter();
    await _pumpRouter(tester, router);

    router.go('/report/');
    await tester.pumpAndSettle();

    expect(find.byType(ErrorPage), findsOneWidget);
  });
}
