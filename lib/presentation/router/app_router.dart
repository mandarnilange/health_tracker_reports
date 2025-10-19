import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/presentation/pages/error/error_page.dart';
import 'package:health_tracker_reports/presentation/pages/home/reports_list_page.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/presentation/pages/report_detail/report_detail_page.dart';
import 'package:health_tracker_reports/presentation/pages/health_log/health_log_detail_page.dart';
import 'package:health_tracker_reports/presentation/pages/settings/settings_page.dart';
import 'package:health_tracker_reports/presentation/pages/trends/comparison_view.dart';
import 'package:health_tracker_reports/presentation/pages/trends/trends_page.dart';
import 'package:health_tracker_reports/presentation/pages/trends/trends_page_args.dart';
import 'package:health_tracker_reports/presentation/pages/upload/upload_page.dart';
import 'package:health_tracker_reports/presentation/pages/upload/review_page.dart';
import 'package:health_tracker_reports/presentation/router/route_names.dart';
import 'package:health_tracker_reports/presentation/pages/export/export_page.dart';
import 'package:health_tracker_reports/presentation/pages/export/export_page_args.dart';

/// Application router configuration using go_router.
///
/// This class manages all navigation routes for the Health Tracker Reports app
/// using declarative routing with go_router.
///
/// Routes:
/// - `/` - Home page with reports list (ReportsListPage)
/// - `/upload` - Upload new report page (UploadPage)
/// - `/report/:id` - Report detail page with dynamic ID parameter (ReportDetailPage)
///
/// Error Handling:
/// - 404 errors and invalid routes are handled by displaying the ErrorPage
class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  /// Create a new instance of the application router.
  static GoRouter createRouter() => GoRouter(
        debugLogDiagnostics: true,
        initialLocation: RouteNames.home,
        errorBuilder: (context, state) => ErrorPage(
          errorMessage: state.error?.toString(),
        ),
        routes: [
          // Home Route - Reports List
          GoRoute(
            path: RouteNames.home,
            name: 'home',
            pageBuilder: (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const ReportsListPage(),
            ),
          ),

          // Upload Route - Upload new report
          GoRoute(
            path: RouteNames.upload,
            name: 'upload',
            pageBuilder: (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const UploadPage(),
            ),
          ),

          // Review Route - Review extracted report
          GoRoute(
            path: RouteNames.review,
            name: 'review',
            pageBuilder: (context, state) {
              final extra = state.extra;
              if (extra is! Report) {
                return MaterialPage<void>(
                  key: state.pageKey,
                  child: const ErrorPage(
                    errorMessage: 'Report data is required',
                  ),
                );
              }

              return MaterialPage<void>(
                key: state.pageKey,
                child: ReviewPage(initialReport: extra),
              );
            },
          ),

          // Report Detail Route - View specific report
          GoRoute(
            path: RouteNames.reportDetail,
            name: 'reportDetail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'];

              // Validate that ID exists
              if (id == null || id.isEmpty) {
                return MaterialPage<void>(
                  key: state.pageKey,
                  child: const ErrorPage(
                    errorMessage: 'Report ID is required',
                  ),
                );
              }

              return MaterialPage<void>(
                key: state.pageKey,
                child: ReportDetailPage(reportId: id),
              );
            },
          ),

          // Trends Route - View biomarker trends
          GoRoute(
            path: RouteNames.trends,
            name: 'trends',
            pageBuilder: (context, state) {
              final extra = state.extra;
              final args = extra is TrendsPageArgs ? extra : null;
              return MaterialPage<void>(
                key: state.pageKey,
                child: TrendsPage(initialArgs: args),
              );
            },
          ),

          // Comparison Route - Compare biomarkers across reports
          GoRoute(
            path: RouteNames.comparison,
            name: 'comparison',
            pageBuilder: (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const ComparisonView(),
            ),
          ),

          // Settings Route - App settings
          GoRoute(
            path: RouteNames.settings,
            name: 'settings',
            pageBuilder: (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const SettingsPage(),
            ),
          ),

          // Health Log Detail Route - View specific health log
          GoRoute(
            path: RouteNames.healthLogDetail,
            name: 'healthLogDetail',
            pageBuilder: (context, state) {
              final extra = state.extra;

              // Validate that HealthLog data is provided
              if (extra is! HealthLog) {
                return MaterialPage<void>(
                  key: state.pageKey,
                  child: const ErrorPage(
                    errorMessage: 'Health log data is required',
                  ),
                );
              }

              return MaterialPage<void>(
                key: state.pageKey,
                child: HealthLogDetailPage(log: extra),
              );
            },
          ),

          // Export Route - CSV/PDF export tools
          GoRoute(
            path: RouteNames.export,
            name: 'export',
            pageBuilder: (context, state) {
              final extra = state.extra;
              if (extra is! ExportPageArgs) {
                return MaterialPage<void>(
                  key: state.pageKey,
                  child: const ErrorPage(
                    errorMessage: 'Export data is required',
                  ),
                );
              }

              return MaterialPage<void>(
                key: state.pageKey,
                child: ExportPage(
                  reports: extra.reports,
                  healthLogs: extra.healthLogs,
                  trendSeries: extra.trendSeries,
                ),
              );
            },
          ),
        ],
      );

  /// Shared router instance used by the application.
  static final router = createRouter();
}
