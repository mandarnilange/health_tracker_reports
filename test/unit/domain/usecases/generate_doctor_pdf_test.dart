import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/domain/entities/doctor_summary_config.dart';
import 'package:health_tracker_reports/domain/entities/summary_statistics.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_summary_statistics.dart';
import 'package:health_tracker_reports/domain/usecases/generate_doctor_pdf.dart';
import 'package:health_tracker_reports/data/datasources/external/pdf_generator_service.dart';
import 'package:health_tracker_reports/core/error/failures.dart';

class MockCalculateSummaryStatistics extends Mock implements CalculateSummaryStatistics {}
class MockPdfGeneratorService extends Mock implements PdfGeneratorService {}

class FakeDoctorSummaryConfig extends Fake implements DoctorSummaryConfig {}
class FakeSummaryStatistics extends Fake implements SummaryStatistics {}

void main() {
  late GenerateDoctorPdf usecase;
  late MockCalculateSummaryStatistics mockCalculateSummaryStatistics;
  late MockPdfGeneratorService mockPdfGeneratorService;

  setUpAll(() {
    registerFallbackValue(FakeDoctorSummaryConfig());
    registerFallbackValue(FakeSummaryStatistics());
  });

  setUp(() {
    mockCalculateSummaryStatistics = MockCalculateSummaryStatistics();
    mockPdfGeneratorService = MockPdfGeneratorService();
    usecase = GenerateDoctorPdf(
      calculateSummaryStatistics: mockCalculateSummaryStatistics,
      pdfGeneratorService: mockPdfGeneratorService,
    );
  });

  final tConfig = DoctorSummaryConfig(
    startDate: DateTime(2023, 1, 1),
    endDate: DateTime(2023, 1, 31),
  );

  final tSummaryStatistics = SummaryStatistics(
    biomarkerTrends: [],
    vitalTrends: [],
    criticalFindings: [],
    dashboard: HealthStatusDashboard(
      glucoseControl: const DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
      lipidPanel: const DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
      kidneyFunction: const DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
      bloodPressure: const DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
      cardiovascular: const DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
    ),
    totalReports: 1,
    totalHealthLogs: 0,
  );

  test('should call CalculateSummaryStatistics and PdfGeneratorService', () async {
    // Arrange
    when(() => mockCalculateSummaryStatistics(any()))
        .thenAnswer((_) async => Right(tSummaryStatistics));
    when(() => mockPdfGeneratorService.generatePdf(any()))
        .thenAnswer((_) async => const Right('/path/to/pdf'));

    // Act
    await usecase(tConfig);

    // Assert
    verify(() => mockCalculateSummaryStatistics(tConfig)).called(1);
    verify(() => mockPdfGeneratorService.generatePdf(tSummaryStatistics)).called(1);
  });

  test('should return a file path on success', () async {
    // Arrange
    when(() => mockCalculateSummaryStatistics(any()))
        .thenAnswer((_) async => Right(tSummaryStatistics));
    when(() => mockPdfGeneratorService.generatePdf(any()))
        .thenAnswer((_) async => const Right('/path/to/pdf'));

    // Act
    final result = await usecase(tConfig);

    // Assert
    expect(result, const Right('/path/to/pdf'));
  });

  test('should return a ValidationFailure if start date is after end date', () async {
    // Arrange
    final invalidConfig = DoctorSummaryConfig(
      startDate: DateTime(2023, 2, 1),
      endDate: DateTime(2023, 1, 31),
    );

    when(() => mockCalculateSummaryStatistics(any()))
        .thenAnswer((_) async => Right(tSummaryStatistics));

    // Act
    final result = await usecase(invalidConfig);

    // Assert
    expect(result, isA<Left<Failure, String>>());
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('should not succeed'),
    );
  });

  test('should return a ValidationFailure if no reports are found', () async {
    // Arrange
    final emptyStats = SummaryStatistics(
      biomarkerTrends: [],
      vitalTrends: [],
      criticalFindings: [],
      dashboard: HealthStatusDashboard(
        glucoseControl: const DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
        lipidPanel: const DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
        kidneyFunction: const DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
        bloodPressure: const DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
        cardiovascular: const DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
      ),
      totalReports: 0,
      totalHealthLogs: 0,
    );
    when(() => mockCalculateSummaryStatistics(any()))
        .thenAnswer((_) async => Right(emptyStats));

    // Act
    final result = await usecase(tConfig);

    // Assert
    expect(result, isA<Left<Failure, String>>());
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('should not succeed'),
    );
  });

  test('should pass includeVitals flag to services', () async {
    // Arrange
    final noVitalsConfig = tConfig.copyWith(includeVitals: false);
    when(() => mockCalculateSummaryStatistics(any()))
        .thenAnswer((_) async => Right(tSummaryStatistics));
    when(() => mockPdfGeneratorService.generatePdf(any()))
        .thenAnswer((_) async => const Right('/path/to/pdf'));

    // Act
    await usecase(noVitalsConfig);

    // Assert
    verify(() => mockCalculateSummaryStatistics(noVitalsConfig)).called(1);
  });

  test('should pass includeFullDataTable flag to services', () async {
    // Arrange
    final fullTableConfig = tConfig.copyWith(includeFullDataTable: true);
    when(() => mockCalculateSummaryStatistics(any()))
        .thenAnswer((_) async => Right(tSummaryStatistics));
    when(() => mockPdfGeneratorService.generatePdf(any()))
        .thenAnswer((_) async => const Right('/path/to/pdf'));

    // Act
    await usecase(fullTableConfig);

    // Assert
    verify(() => mockCalculateSummaryStatistics(fullTableConfig)).called(1);
  });

}
