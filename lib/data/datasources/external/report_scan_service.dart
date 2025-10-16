import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Types of supported scan inputs.
enum ScanSource { pdf, images }

/// Request describing a scan invocation delegated to the native layer.
class ReportScanRequest {
  const ReportScanRequest({
    required this.source,
    required this.uri,
    this.imageUris = const [],
    this.pageLimit,
  });

  final ScanSource source;
  final String uri;
  final List<String> imageUris;
  final int? pageLimit;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'source': source.name,
        'uri': uri,
        'imageUris': imageUris,
        if (pageLimit != null) 'pageLimit': pageLimit,
      };
}

/// Structured biomarker information emitted directly from native OCR passes.
class StructuredBiomarker {
  const StructuredBiomarker({
    required this.name,
    this.value,
    this.unit,
    this.referenceMin,
    this.referenceMax,
  });

  final String name;
  final String? value;
  final String? unit;
  final String? referenceMin;
  final String? referenceMax;

  factory StructuredBiomarker.fromMap(Map<dynamic, dynamic> map) {
    return StructuredBiomarker(
      name: (map['name'] ?? '') as String,
      value: map['value']?.toString(),
      unit: map['unit']?.toString(),
      referenceMin: map['referenceMin']?.toString(),
      referenceMax: map['referenceMax']?.toString(),
    );
  }
}

/// Payload emitted with structured results.
class ReportScanPayload {
  const ReportScanPayload({
    this.rawText = '',
    this.biomarkers = const <StructuredBiomarker>[],
  });

  final String rawText;
  final List<StructuredBiomarker> biomarkers;

  factory ReportScanPayload.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const ReportScanPayload();
    }
    final biomarkerMaps = map['biomarkers'];
    final biomarkers = biomarkerMaps is Iterable
        ? biomarkerMaps
            .whereType<Map<dynamic, dynamic>>()
            .map(StructuredBiomarker.fromMap)
            .toList(growable: false)
        : const <StructuredBiomarker>[];
    return ReportScanPayload(
      rawText: map['rawText']?.toString() ?? '',
      biomarkers: biomarkers,
    );
  }
}

/// Base class for events emitted while scanning.
abstract class ReportScanEvent {
  const ReportScanEvent();
}

class ReportScanEventProgress extends ReportScanEvent {
  const ReportScanEventProgress({
    required this.page,
    this.totalPages,
  });

  final int page;
  final int? totalPages;
}

class ReportScanEventStructured extends ReportScanEvent {
  const ReportScanEventStructured({
    required this.page,
    this.totalPages,
    required this.payload,
  });

  final int page;
  final int? totalPages;
  final ReportScanPayload payload;
}

class ReportScanEventText extends ReportScanEvent {
  const ReportScanEventText({
    required this.page,
    this.totalPages,
    required this.text,
  });

  final int page;
  final int? totalPages;
  final String text;
}

class ReportScanEventError extends ReportScanEvent {
  const ReportScanEventError({
    required this.code,
    this.message,
  });

  final String code;
  final String? message;
}

class ReportScanEventComplete extends ReportScanEvent {
  const ReportScanEventComplete();
}

/// Contract for invoking native scanning capabilities.
abstract class ReportScanService {
  Stream<ReportScanEvent> scanReport(ReportScanRequest request);
}

typedef EventStreamFactory = Stream<dynamic> Function(
    ReportScanRequest request);

/// MethodChannel/EventChannel backed implementation.
@LazySingleton(as: ReportScanService)
class ReportScanServiceImpl implements ReportScanService {
  ReportScanServiceImpl()
      : _methodChannel = const MethodChannel(_defaultMethodChannel),
        _eventStreamFactory = null;

  @visibleForTesting
  ReportScanServiceImpl.test({
    MethodChannel? methodChannel,
    EventStreamFactory? eventStreamFactory,
  })  : _methodChannel =
            methodChannel ?? const MethodChannel(_defaultMethodChannel),
        _eventStreamFactory = eventStreamFactory;

  static const String _defaultMethodChannel = 'report_scan/methods';
  static const String _defaultEventChannel = 'report_scan/events';

  final MethodChannel _methodChannel;
  final EventStreamFactory? _eventStreamFactory;

  @override
  Stream<ReportScanEvent> scanReport(ReportScanRequest request) {
    late StreamSubscription<dynamic> subscription;
    final controller = StreamController<ReportScanEvent>();

    controller.onListen = () async {
      try {
        await _methodChannel.invokeMethod<void>('startScan', request.toJson());
      } on PlatformException catch (error) {
        controller.add(
          ReportScanEventError(
            code: error.code,
            message: error.message,
          ),
        );
        await controller.close();
        return;
      }

      final stream = _eventStreamFactory != null
          ? _eventStreamFactory!(request)
          : EventChannel(_defaultEventChannel)
              .receiveBroadcastStream(request.toJson());

      subscription = stream.listen(
        (event) => controller.add(_mapEvent(event)),
        onError: (Object error, StackTrace stackTrace) {
          controller.add(
            ReportScanEventError(
              code: 'stream_error',
              message: error.toString(),
            ),
          );
        },
        onDone: () async {
          if (!controller.isClosed) {
            await controller.close();
          }
        },
        cancelOnError: false,
      );
    };

    controller.onCancel = () async {
      if (controller.isClosed) return;
      await subscription.cancel();
    };

    return controller.stream;
  }

  ReportScanEvent _mapEvent(dynamic event) {
    if (event is! Map) {
      return const ReportScanEventError(
        code: 'invalid_event',
        message: 'Event is not a map',
      );
    }

    final type = event['type']?.toString();
    switch (type) {
      case 'progress':
        return ReportScanEventProgress(
          page: _asInt(event['page']) ?? 0,
          totalPages: _asInt(event['totalPages']),
        );
      case 'structured':
        return ReportScanEventStructured(
          page: _asInt(event['page']) ?? 0,
          totalPages: _asInt(event['totalPages']),
          payload: ReportScanPayload.fromMap(
            event['payload'] as Map<dynamic, dynamic>?,
          ),
        );
      case 'text':
        return ReportScanEventText(
          page: _asInt(event['page']) ?? 0,
          totalPages: _asInt(event['totalPages']),
          text: event['text']?.toString() ?? '',
        );
      case 'error':
        return ReportScanEventError(
          code: event['code']?.toString() ?? 'unknown',
          message: event['message']?.toString(),
        );
      case 'complete':
        return const ReportScanEventComplete();
      default:
        return ReportScanEventError(
          code: 'unsupported_event',
          message: 'Unsupported event type: $type',
        );
    }
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
