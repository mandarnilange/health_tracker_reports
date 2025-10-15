
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:health_tracker_reports/domain/usecases/save_report.dart';
import 'package:mocktail/mocktail.dart';

class MockReportRepository extends Mock implements ReportRepository {}

void main() {
  late SaveReport usecase;
  late MockReportRepository mockReportRepository;

  setUp(() {
    mockReportRepository = MockReportRepository();
    usecase = SaveReport(repository: mockReportRepository);
    registerFallbackValue(Report(
      id: '1',
      date: DateTime.now(),
      labName: 'Test Lab',
      biomarkers: [],
      originalFilePath: '/path/to/file',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  });

  final tReport = Report(
    id: '1',
    date: DateTime.now(),
    labName: 'Test Lab',
    biomarkers: [],
    originalFilePath: '/path/to/file',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  test('should call the repository to save the report', () async {
    // Arrange
    when(() => mockReportRepository.saveReport(any()))
        .thenAnswer((_) async => Right(tReport));

    // Act
    final result = await usecase(tReport);

    // Assert
    expect(result, Right(tReport));
    verify(() => mockReportRepository.saveReport(tReport));
    verifyNoMoreInteractions(mockReportRepository);
  });

  test('should generate a new id if the report id is empty', () async {
    // Arrange
    final tReportWithEmptyId = tReport.copyWith(id: '');
    when(() => mockReportRepository.saveReport(any()))
        .thenAnswer((_) async => Right(tReport));

    // Act
    await usecase(tReportWithEmptyId);

    // Assert
    final captured = verify(() => mockReportRepository.saveReport(captureAny())).captured;
    expect(captured.first.id, isNotEmpty);
  });

  test('should return a CacheFailure when the call to repository is unsuccessful', () async {
    // Arrange
    when(() => mockReportRepository.saveReport(any()))
        .thenAnswer((_) async => Left(CacheFailure()));

    // Act
    final result = await usecase(tReport);

    // Assert
    expect(result, Left(CacheFailure()));
  });
}
