import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file.dart';
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file_llm.dart';
import 'package:mocktail/mocktail.dart';

class _MockExtractReportFromFileLlm extends Mock
    implements ExtractReportFromFileLlm {}

void main() {
  late ExtractReportFromFile usecase;
  late _MockExtractReportFromFileLlm mockDelegate;

  setUp(() {
    mockDelegate = _MockExtractReportFromFileLlm();
    usecase = ExtractReportFromFile(delegate: mockDelegate);
  });

  group('ExtractReportFromFile (delegate)', () {
    const filePath = '/tmp/report.pdf';
    final report = Report(
      id: 'r1',
      date: DateTime(2024, 5, 1),
      labName: 'Test Lab',
      biomarkers: [
        Biomarker(
          id: 'b1',
          name: 'Glucose',
          value: 95,
          unit: 'mg/dL',
          referenceRange: const ReferenceRange(min: 70, max: 110),
          measuredAt: DateTime(2024, 5, 1),
        ),
      ],
      originalFilePath: '/tmp/report.pdf',
      createdAt: DateTime(2024, 5, 1, 10),
      updatedAt: DateTime(2024, 5, 1, 10),
    );
    final failure = const ValidationFailure(message: 'bad file');

    test('forwards successful extraction to delegate', () async {
      // Arrange
      when(() => mockDelegate(filePath))
          .thenAnswer((_) async => Right(report));

      // Act
      final result = await usecase(filePath);

      // Assert
      expect(result, Right(report));
      verify(() => mockDelegate(filePath)).called(1);
      verifyNoMoreInteractions(mockDelegate);
    });

    test('propagates failure from delegate', () async {
      // Arrange
      when(() => mockDelegate(filePath))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await usecase(filePath);

      // Assert
      expect(result, Left(failure));
      verify(() => mockDelegate(filePath)).called(1);
    });
  });
}
