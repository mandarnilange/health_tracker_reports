import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:mocktail/mocktail.dart';

class MockReportRepository extends Mock implements ReportRepository {}

void main() {
  late GetAllReports usecase;
  late MockReportRepository mockReportRepository;

  setUp(() {
    mockReportRepository = MockReportRepository();
    usecase = GetAllReports(repository: mockReportRepository);
  });

  final tReport1 = Report(
    id: '1',
    date: DateTime(2023, 1, 1),
    labName: 'Test Lab',
    biomarkers: [],
    originalFilePath: '/path/to/file',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  final tReport2 = Report(
    id: '2',
    date: DateTime(2023, 1, 2),
    labName: 'Test Lab',
    biomarkers: [],
    originalFilePath: '/path/to/file',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  final tReportList = [tReport1, tReport2];

  test('should get all reports from the repository', () async {
    // Arrange
    when(() => mockReportRepository.getAllReports())
        .thenAnswer((_) async => Right(tReportList));

    // Act
    final result = await usecase();

    // Assert
    result.fold(
      (l) => fail('should not return a failure'),
      (r) => expect(r, tReportList),
    );
    verify(() => mockReportRepository.getAllReports());
    verifyNoMoreInteractions(mockReportRepository);
  });

  test('should return an empty list when no reports are found', () async {
    // Arrange
    when(() => mockReportRepository.getAllReports())
        .thenAnswer((_) async => Right([]));

    // Act
    final result = await usecase();

    // Assert
    result.fold(
      (l) => fail('should not return a failure'),
      (r) => expect(r, []),
    );
  });

  test('should return reports sorted by date descending', () async {
    // Arrange
    final tUnsortedList = [tReport1, tReport2];
    final tSortedList = [tReport2, tReport1];
    when(() => mockReportRepository.getAllReports())
        .thenAnswer((_) async => Right(tUnsortedList));

    // Act
    final result = await usecase();

    // Assert
    result.fold(
      (l) => fail('should not return a failure'),
      (r) => expect(r, tSortedList),
    );
  });

  test(
      'should return a CacheFailure when the call to repository is unsuccessful',
      () async {
    // Arrange
    when(() => mockReportRepository.getAllReports())
        .thenAnswer((_) async => Left(CacheFailure()));

    // Act
    final result = await usecase();

    // Assert
    expect(result, Left(CacheFailure()));
  });
}
