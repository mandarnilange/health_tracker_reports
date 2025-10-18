import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/services/report_scan_service.dart';
import 'package:health_tracker_reports/data/datasources/external/report_scan_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannelName = 'report_scan/methods';
  late MethodChannel methodChannel;
  late List<MethodCall> recordedCalls;

  setUp(() {
    methodChannel = const MethodChannel(methodChannelName);
    recordedCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (methodCall) async {
      recordedCalls.add(methodCall);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  ReportScanService createService(
      Stream<dynamic> Function(ReportScanRequest) factory) {
    return ReportScanServiceImpl.test(
      methodChannel: methodChannel,
      eventStreamFactory: factory,
    );
  }

  group('ReportScanServiceImpl', () {
    test('invokes native startScan with serialized request', () async {
      final requests = <ReportScanRequest>[
        const ReportScanRequest(
          source: ScanSource.pdf,
          uri: 'file:///sample.pdf',
          imageUris: [],
        ),
      ];

      final controller = StreamController<dynamic>();

      final service = createService((_) => controller.stream);

      final subscription = service.scanReport(requests.first).listen((_) {});

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(recordedCalls, hasLength(1));
      expect(recordedCalls.first.method, equals('startScan'));
      expect(
        recordedCalls.first.arguments,
        equals({
          'uri': 'file:///sample.pdf',
          'source': 'pdf',
          'imageUris': <String>[],
        }),
      );

      await subscription.cancel();
      await controller.close();
    });

    test('maps structured payload events emitted from native stream', () async {
      final request = const ReportScanRequest(
        source: ScanSource.images,
        uri: 'file:///unused',
        imageUris: ['file:///a', 'file:///b'],
      );

      final events = [
        {'type': 'progress', 'page': 1, 'totalPages': 2},
        {
          'type': 'structured',
          'page': 1,
          'totalPages': 2,
          'payload': {
            'rawText': 'Patient Name : Alice Example\nHemoglobin 13.5 g/dL',
            'lines': [
              {
                'text': 'Patient Name : Alice Example',
                'boundingBox': {'x': 0.1, 'y': 0.9, 'width': 0.8, 'height': 0.05},
              },
              {
                'text': 'Hemoglobin 13.5 g/dL 12-17',
                'boundingBox': {'x': 0.2, 'y': 0.6, 'width': 0.7, 'height': 0.05},
              },
            ],
          },
        },
        {'type': 'complete'},
      ];

      final service =
          createService((_) => Stream<dynamic>.fromIterable(events));

      final expectation = expectLater(
        service.scanReport(request),
        emitsInOrder([
          isA<ReportScanEventProgress>().having((e) => e.page, 'page', 1),
          predicate<ReportScanEventStructured>((event) {
            expect(event.page, equals(1));
            expect(event.totalPages, equals(2));
            expect(event.payload.rawText,
                'Patient Name : Alice Example\nHemoglobin 13.5 g/dL');
            expect(event.payload.lines, hasLength(2));
            final firstLine = event.payload.lines.first;
            expect(firstLine.text, 'Patient Name : Alice Example');
            expect(firstLine.boundingBox.x, closeTo(0.1, 1e-6));
            return true;
          }),
          isA<ReportScanEventComplete>(),
        ]),
      );

      await expectation;
    });

    test('emits error event when native stream provides error map', () async {
      final service = createService(
        (_) => Stream<dynamic>.fromIterable([
          {
            'type': 'error',
            'code': 'scan_failed',
            'message': 'Scanning failed',
          },
        ]),
      );

      await expectLater(
        service.scanReport(
          const ReportScanRequest(
            source: ScanSource.pdf,
            uri: 'file:///sample.pdf',
            imageUris: [],
          ),
        ),
        emitsInOrder([
          isA<ReportScanEventError>()
              .having((e) => e.code, 'code', 'scan_failed')
              .having((e) => e.message, 'message', 'Scanning failed'),
        ]),
      );
    });
  });
}
