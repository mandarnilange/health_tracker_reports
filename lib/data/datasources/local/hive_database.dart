import 'package:hive/hive.dart';

/// Manages Hive database initialization and box access.
///
/// This class provides a centralized way to initialize Hive and access
/// the application's data boxes. It uses static methods and properties
/// for simplicity and global access.
class HiveDatabase {
  /// Box name for storing reports
  static const String reportsBoxName = 'reports';

  /// Box name for storing app configuration
  static const String configBoxName = 'config';

  /// Box for storing reports as JSON maps
  static late Box<Map<dynamic, dynamic>> reportsBox;

  /// Box for storing app configuration as JSON maps
  static late Box<Map<dynamic, dynamic>> configBox;

  /// Initializes Hive with the given path and opens required boxes.
  ///
  /// This method must be called before accessing any boxes.
  /// The [path] parameter specifies where Hive should store its data.
  /// The optional [hiveInstance] parameter allows for dependency injection in tests.
  static Future<void> initialize(
    String path, {
    HiveInterface? hiveInstance,
  }) async {
    final hive = hiveInstance ?? Hive;

    // Initialize Hive with the provided path
    hive.init(path);

    // Open the boxes
    reportsBox = await hive.openBox<Map<dynamic, dynamic>>(reportsBoxName);
    configBox = await hive.openBox<Map<dynamic, dynamic>>(configBoxName);
  }

  /// Closes all Hive boxes and cleans up resources.
  ///
  /// This should be called when the app is shutting down.
  /// The optional [hiveInstance] parameter allows for dependency injection in tests.
  static Future<void> close({HiveInterface? hiveInstance}) async {
    final hive = hiveInstance ?? Hive;
    await hive.close();
  }
}
