import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/domain/entities/doctor_summary_config.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/summary_statistics.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_summary_statistics.dart';
import 'package:health_tracker_reports/domain/usecases/get_biomarker_trend.dart';
import 'package:health_tracker_reports/domain/usecases/get_vital_trend.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_trend.dart';
import 'package:health_tracker_reports/core/error/failures.dart';

class MockReportRepository extends Mock implements ReportRepository {}
class MockHealthLogRepository extends Mock implements HealthLogRepository {}
class MockGetBiomarkerTrend extends Mock implements GetBiomarkerTrend {}
class MockGetVitalTrend extends Mock implements GetVitalTrend {}
class MockCalculateTrend extends Mock implements CalculateTrend {}

void main() {
  late CalculateSummaryStatistics usecase;
  late MockReportRepository mockReportRepository;
  late MockHealthLogRepository mockHealthLogRepository;
  late MockGetBiomarkerTrend mockGetBiomarkerTrend;
  late MockGetVitalTrend mockGetVitalTrend;
  late MockCalculateTrend mockCalculateTrend;

  setUp(() {
    mockReportRepository = MockReportRepository();
    mockHealthLogRepository = MockHealthLogRepository();
    mockGetBiomarkerTrend = MockGetBiomarkerTrend();
    mockGetVitalTrend = MockGetVitalTrend();
    mockCalculateTrend = MockCalculateTrend();
    usecase = CalculateSummaryStatistics(
      reportRepository: mockReportRepository,
      healthLogRepository: mockHealthLogRepository,
      getBiomarkerTrend: mockGetBiomarkerTrend,
      getVitalTrend: mockGetVitalTrend,
      calculateTrend: mockCalculateTrend,
    );

    when(() => mockCalculateTrend(any()))
        .thenAnswer((_) => const Left(ValidationFailure(message: 'Not enough data')));
    when(
      () => mockGetVitalTrend(
        any<VitalType>(),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => const Right([]));
  });

  final tConfig = DoctorSummaryConfig(
    startDate: DateTime(2023, 1, 1),
    endDate: DateTime(2023, 1, 31),
  );

  test('should fetch reports and health logs from repositories', () async {
    // Arrange
    when(() => mockReportRepository.getReportsByDateRange(any(), any()))
        .thenAnswer((_) async => const Right([]));
    when(() => mockHealthLogRepository.getHealthLogsByDateRange(any(), any()))
        .thenAnswer((_) async => const Right([]));
    when(() => mockGetBiomarkerTrend(any(), startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
        .thenAnswer((_) async => const Right([]));

    // Act
    await usecase(tConfig);

    // Assert
    verify(() => mockReportRepository.getReportsByDateRange(tConfig.startDate, tConfig.endDate)).called(1);
    verify(() => mockHealthLogRepository.getHealthLogsByDateRange(tConfig.startDate, tConfig.endDate)).called(1);
  });

  test('should return a SummaryStatistics model on success', () async {
    // Arrange
    when(() => mockReportRepository.getReportsByDateRange(any(), any()))
        .thenAnswer((_) async => const Right([]));
    when(() => mockHealthLogRepository.getHealthLogsByDateRange(any(), any()))
        .thenAnswer((_) async => const Right([]));
    when(() => mockGetBiomarkerTrend(any(), startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
        .thenAnswer((_) async => const Right([]));

    // Act
    final result = await usecase(tConfig);

    // Assert
    expect(result, isA<Right<Failure, SummaryStatistics>>());
  });

  test('should identify the top out-of-range biomarker as a critical finding', () async {
    // Arrange
    final outOfRangeBiomarker = Biomarker(
      id: '1', name: 'Glucose', value: 150, unit: 'mg/dL', 
      referenceRange: ReferenceRange(min: 70, max: 100), measuredAt: DateTime.now()
    );
    final normalBiomarker = Biomarker(
      id: '2', name: 'HDL', value: 50, unit: 'mg/dL', 
      referenceRange: ReferenceRange(min: 40, max: 60), measuredAt: DateTime.now()
    );
    final tReport = Report(
      id: 'r1', date: tConfig.startDate, labName: 'Test Lab', 
      biomarkers: [outOfRangeBiomarker, normalBiomarker], 
      originalFilePath: '', createdAt: DateTime.now(), updatedAt: DateTime.now()
    );

    when(() => mockReportRepository.getReportsByDateRange(any(), any()))
        .thenAnswer((_) async => Right([tReport]));
    when(() => mockHealthLogRepository.getHealthLogsByDateRange(any(), any()))
        .thenAnswer((_) async => const Right([]));
    when(() => mockGetBiomarkerTrend(any(), startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
        .thenAnswer((_) async => const Right([]));

    // Act
    final result = await usecase(tConfig);

    // Assert
    result.fold(
      (failure) => fail('should not fail'),
      (summary) {
        expect(summary.criticalFindings, hasLength(1));
        expect(summary.criticalFindings.first.category, 'Glucose');
        expect(summary.criticalFindings.first.finding, contains('150'));
      },
    );
  });

  test('should prioritize and limit critical findings to the top 3 most severe', () async {
    // Arrange
    final glucose = Biomarker(id: 'g', name: 'Glucose', value: 150, unit: 'mg/dL', referenceRange: ReferenceRange(min: 70, max: 100), measuredAt: DateTime.now()); // Severity: (150-100)/100 = 0.5
    final ldl = Biomarker(id: 'l', name: 'LDL', value: 200, unit: 'mg/dL', referenceRange: ReferenceRange(min: 0, max: 100), measuredAt: DateTime.now()); // Severity: (200-100)/100 = 1.0
    final hdl = Biomarker(id: 'h', name: 'HDL', value: 30, unit: 'mg/dL', referenceRange: ReferenceRange(min: 40, max: 60), measuredAt: DateTime.now()); // Severity: (40-30)/40 = 0.25
    final triglycerides = Biomarker(id: 't', name: 'Triglycerides', value: 400, unit: 'mg/dL', referenceRange: ReferenceRange(min: 0, max: 150), measuredAt: DateTime.now()); // Severity: (400-150)/150 = 1.66
    final normal = Biomarker(id: 'n', name: 'Normal', value: 100, unit: 'mg/dL', referenceRange: ReferenceRange(min: 80, max: 120), measuredAt: DateTime.now());

    final tReport1 = Report(id: 'r1', date: tConfig.startDate, labName: 'Lab1', biomarkers: [glucose, ldl], originalFilePath: '', createdAt: DateTime.now(), updatedAt: DateTime.now());
    final tReport2 = Report(id: 'r2', date: tConfig.endDate, labName: 'Lab2', biomarkers: [hdl, triglycerides, normal], originalFilePath: '', createdAt: DateTime.now(), updatedAt: DateTime.now());

    when(() => mockReportRepository.getReportsByDateRange(any(), any()))
        .thenAnswer((_) async => Right([tReport1, tReport2]));
    when(() => mockHealthLogRepository.getHealthLogsByDateRange(any(), any()))
        .thenAnswer((_) async => const Right([]));
    when(() => mockGetBiomarkerTrend(any(), startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
        .thenAnswer((_) async => const Right([]));

    // Act
    final result = await usecase(tConfig);

    // Assert
    result.fold(
      (failure) => fail('should not fail'),
      (summary) {
        expect(summary.criticalFindings, hasLength(3));
        expect(summary.criticalFindings[0].category, 'Triglycerides'); // Most severe
        expect(summary.criticalFindings[1].category, 'LDL'); // Second most severe
        expect(summary.criticalFindings[2].category, 'Glucose'); // Third most severe
      },
    );
  });

  test('should determine trend directions for biomarkers', () async {
    // Arrange
    final glucoseBiomarker = Biomarker(id: 'g1', name: 'Glucose', value: 100, unit: 'mg/dL', referenceRange: ReferenceRange(min: 70, max: 100), measuredAt: DateTime.now());
    final tReport = Report(id: 'r1', date: tConfig.startDate, labName: 'Lab1', biomarkers: [glucoseBiomarker], originalFilePath: '', createdAt: DateTime.now(), updatedAt: DateTime.now());
    final tTrendDataPoints = [TrendDataPoint(date: DateTime.now(), value: 100, unit: 'mg/dL', reportId: 'r1', status: BiomarkerStatus.normal)];
    final tTrendAnalysis = TrendAnalysis(direction: TrendDirection.stable, percentageChange: 0, firstValue: 100, lastValue: 100, dataPointsCount: 1);

    when(() => mockReportRepository.getReportsByDateRange(any(), any()))
        .thenAnswer((_) async => Right([tReport]));
    when(() => mockHealthLogRepository.getHealthLogsByDateRange(any(), any()))
        .thenAnswer((_) async => const Right([]));
    when(() => mockGetBiomarkerTrend(any(), startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
        .thenAnswer((_) async => Right(tTrendDataPoints));
    when(() => mockCalculateTrend(any()))
        .thenAnswer((_) => Right(tTrendAnalysis));

    // Act
    final result = await usecase(tConfig);

    // Assert
    result.fold(
      (failure) => fail('should not fail'),
      (summary) {
        verify(() => mockGetBiomarkerTrend('Glucose', startDate: tConfig.startDate, endDate: tConfig.endDate)).called(1);
        verify(() => mockCalculateTrend(tTrendDataPoints)).called(1);
        expect(summary.biomarkerTrends, hasLength(1));
        expect(summary.biomarkerTrends.first.biomarkerName, 'Glucose');
                expect(summary.biomarkerTrends.first.trend, tTrendAnalysis);
              },
            );
          });
        
          test('should build the health status dashboard correctly', () async {
            // Arrange
            final glucose = Biomarker(id: 'g', name: 'Glucose', value: 110, unit: 'mg/dL', referenceRange: ReferenceRange(min: 70, max: 100), measuredAt: DateTime(2023, 1, 15));
            final tReport = Report(id: 'r1', date: tConfig.startDate, labName: 'Lab1', biomarkers: [glucose], originalFilePath: '', createdAt: DateTime.now(), updatedAt: DateTime.now());
            final tTrendAnalysis = TrendAnalysis(direction: TrendDirection.increasing, percentageChange: 10, firstValue: 100, lastValue: 110, dataPointsCount: 2);
        
            when(() => mockReportRepository.getReportsByDateRange(any(), any()))
                .thenAnswer((_) async => Right([tReport]));
            when(() => mockHealthLogRepository.getHealthLogsByDateRange(any(), any()))
                .thenAnswer((_) async => const Right([]));
            when(() => mockGetBiomarkerTrend(any(), startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
                .thenAnswer((_) async => Right([TrendDataPoint(date: DateTime.now(), value: 110, unit: 'mg/dL', reportId: 'r1', status: BiomarkerStatus.high)]));
            when(() => mockCalculateTrend(any()))
                .thenAnswer((_) => Right(tTrendAnalysis));
        
            // Act
            final result = await usecase(tConfig);
        
            // Assert
            result.fold(
              (failure) => fail('should not fail'),
              (summary) {
                expect(summary.dashboard.glucoseControl.status, 'High');
                expect(summary.dashboard.glucoseControl.trend, 'Worsening');
                        expect(summary.dashboard.glucoseControl.latestValue, '110 mg/dL');
                      },
                    );
                  });
                
                  test('should build the full dashboard with multiple categories', () async {
                    // Arrange
                    final ldl = Biomarker(id: 'ldl', name: 'LDL', value: 130, unit: 'mg/dL', referenceRange: ReferenceRange(min: 0, max: 100), measuredAt: DateTime(2023, 1, 10));
                    final creatinine = Biomarker(id: 'cr', name: 'Creatinine', value: 1.2, unit: 'mg/dL', referenceRange: ReferenceRange(min: 0.6, max: 1.2), measuredAt: DateTime(2023, 1, 5));
                    final tReport = Report(id: 'r1', date: tConfig.startDate, labName: 'Lab1', biomarkers: [ldl, creatinine], originalFilePath: '', createdAt: DateTime.now(), updatedAt: DateTime.now());
                
                    when(() => mockReportRepository.getReportsByDateRange(any(), any()))
                        .thenAnswer((_) async => Right([tReport]));
                    when(() => mockHealthLogRepository.getHealthLogsByDateRange(any(), any()))
                        .thenAnswer((_) async => const Right([]));
                    when(() => mockGetBiomarkerTrend(any(), startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
                        .thenAnswer((_) async => const Right([]));
                
                    // Act
                    final result = await usecase(tConfig);
                
                    // Assert
                    result.fold(
                      (failure) => fail('should not fail'),
                      (summary) {
                        expect(summary.dashboard.lipidPanel.status, 'High');
                        expect(summary.dashboard.kidneyFunction.status, 'Normal');
                      },
                    );
                  });
                
                }
                
