import 'dart:async';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:health_tracker_reports/domain/services/report_scan_service.dart';

/// Extension methods for parsing domain types from native platform data.
extension StructuredBiomarkerParser on StructuredBiomarker {
  static StructuredBiomarker fromMap(Map<dynamic, dynamic> map) {
    return StructuredBiomarker(
      name: (map['name'] ?? '') as String,
      value: map['value']?.toString(),
      unit: map['unit']?.toString(),
      referenceMin: map['referenceMin']?.toString(),
      referenceMax: map['referenceMax']?.toString(),
    );
  }
}

extension ReportScanPayloadParser on ReportScanPayload {
  static ReportScanPayload fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const ReportScanPayload();
    }
    final biomarkerMaps = map['biomarkers'];
    final biomarkers = biomarkerMaps is Iterable
        ? biomarkerMaps
            .whereType<Map<dynamic, dynamic>>()
            .map(StructuredBiomarkerParser.fromMap)
            .toList(growable: false)
        : const <StructuredBiomarker>[];

    final lineMaps = map['lines'];
    final lines = lineMaps is Iterable
        ? lineMaps
            .whereType<Map<dynamic, dynamic>>()
            .map(RecognizedLineParser.fromMap)
            .toList(growable: false)
        : const <RecognizedLine>[];

    final metadataMap = map['metadata'];
    final metadata = metadataMap is Map
        ? metadataMap.map((key, value) => MapEntry(key.toString(), value))
        : null;

    return ReportScanPayload(
      rawText: map['rawText']?.toString() ?? '',
      biomarkers: biomarkers,
      lines: lines,
      metadata: metadata,
    );
  }
}

extension RecognizedLineParser on RecognizedLine {
  static RecognizedLine fromMap(Map<dynamic, dynamic> map) {
    final text = map['text']?.toString() ?? '';
    final boxMap = map['boundingBox'];
    final boundingBox = BoundingBoxParser.fromMap(boxMap);
    return RecognizedLine(text: text, boundingBox: boundingBox);
  }
}

extension BoundingBoxParser on BoundingBox {
  static BoundingBox fromMap(dynamic map) {
    if (map is Map) {
      double parse(dynamic value) =>
          value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

      return BoundingBox(
        x: parse(map['x']),
        y: parse(map['y']),
        width: parse(map['width']),
        height: parse(map['height']),
      );
    }

    return const BoundingBox(x: 0, y: 0, width: 0, height: 0);
  }
}

typedef EventStreamFactory = Stream<dynamic> Function(
    ReportScanRequest request);

/// MethodChannel/EventChannel backed implementation.
@LazySingleton(as: ReportScanService)
class ReportScanServiceImpl implements ReportScanService {
  ReportScanServiceImpl()
      : _methodChannel = const MethodChannel(_defaultMethodChannel),
        _eventStreamFactory = null;

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
          payload: ReportScanPayloadParser.fromMap(
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
