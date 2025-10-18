import 'package:equatable/equatable.dart';

/// Represents the download progress of a model file.
///
/// This entity tracks download state and progress for ML model downloads.
class DownloadProgress extends Equatable {
  /// Unique identifier for the model being downloaded
  final String modelId;

  /// Number of bytes downloaded so far
  final int downloaded;

  /// Total size of the file in bytes
  final int total;

  /// Current download status
  final DownloadStatus status;

  /// Optional error message if download failed
  final String? errorMessage;

  /// Creates a [DownloadProgress] with the given properties.
  const DownloadProgress({
    required this.modelId,
    required this.downloaded,
    required this.total,
    required this.status,
    this.errorMessage,
  });

  /// Creates a progress instance for an idle/not started download
  factory DownloadProgress.idle(String modelId) {
    return DownloadProgress(
      modelId: modelId,
      downloaded: 0,
      total: 0,
      status: DownloadStatus.idle,
    );
  }

  /// Creates a progress instance for a downloading state
  factory DownloadProgress.downloading(
    String modelId,
    int downloaded,
    int total,
  ) {
    return DownloadProgress(
      modelId: modelId,
      downloaded: downloaded,
      total: total,
      status: DownloadStatus.downloading,
    );
  }

  /// Creates a progress instance for a completed download
  factory DownloadProgress.completed(String modelId, int total) {
    return DownloadProgress(
      modelId: modelId,
      downloaded: total,
      total: total,
      status: DownloadStatus.completed,
    );
  }

  /// Creates a progress instance for a failed download
  factory DownloadProgress.failed(String modelId, String error) {
    return DownloadProgress(
      modelId: modelId,
      downloaded: 0,
      total: 0,
      status: DownloadStatus.failed,
      errorMessage: error,
    );
  }

  /// Calculate download progress percentage (0.0 to 1.0)
  double get progress {
    if (total == 0) return 0.0;
    return downloaded / total;
  }

  /// Check if download is complete
  bool get isCompleted => status == DownloadStatus.completed;

  /// Check if download is in progress
  bool get isDownloading => status == DownloadStatus.downloading;

  /// Check if download has failed
  bool get isFailed => status == DownloadStatus.failed;

  @override
  List<Object?> get props => [modelId, downloaded, total, status, errorMessage];
}

/// Enum representing the status of a download
enum DownloadStatus {
  /// Download not started
  idle,

  /// Download in progress
  downloading,

  /// Download completed successfully
  completed,

  /// Download failed
  failed,
}
