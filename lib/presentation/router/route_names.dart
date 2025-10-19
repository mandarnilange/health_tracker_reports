/// Route path constants for the Health Tracker Reports app.
///
/// This class contains all route paths used throughout the application
/// for navigation with go_router.
class RouteNames {
  RouteNames._();

  /// Home route - displays the list of reports
  static const String home = '/';

  /// Upload route - allows users to upload new reports
  static const String upload = '/upload';

  /// Review route - allows users to edit extracted report before saving
  static const String review = '/review';

  /// Report detail route - displays details of a specific report
  /// Use with report ID parameter: /report/:id
  static const String reportDetail = '/report/:id';

  /// Trends route - displays biomarker trends over time
  static const String trends = '/trends';

  /// Comparison route - allows users to compare biomarkers across multiple reports
  static const String comparison = '/comparison';

  /// Settings route - allows users to configure app settings
  static const String settings = '/settings';

  /// Health log detail route - displays details of a specific health log
  /// Use with health log ID parameter: /health-log/:id
  static const String healthLogDetail = '/health-log/:id';

  /// Export route - provides CSV/PDF export actions
  static const String export = '/export';
  static const String exportName = 'export';

  /// Helper method to generate report detail route with ID
  static String reportDetailWithId(String id) => '/report/$id';

  /// Helper method to generate health log detail route with ID
  static String healthLogDetailWithId(String id) => '/health-log/$id';
}
