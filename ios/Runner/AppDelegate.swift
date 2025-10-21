import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    self.preventBackup() // Exclude from backup
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func preventBackup() {
    let fileManager = FileManager.default
    guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
        return
    }

    // This path should ideally be the same one used by Hive in the Flutter app.
    // We assume a default path here.
    let hivePath = appSupportURL.appendingPathComponent("health_tracker_reports")

    if !fileManager.fileExists(atPath: hivePath.path) {
        do {
            try fileManager.createDirectory(at: hivePath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create directory for backup exclusion: \(error)")
            return
        }
    }

    var url = hivePath
    var resourceValues = URLResourceValues()
    resourceValues.isExcludedFromBackup = true
    do {
        try url.setResourceValues(resourceValues)
        print("Successfully excluded app data path from backup.")
    } catch {
        print("Failed to exclude app data path from backup: \(error)")
    }
  }
}
