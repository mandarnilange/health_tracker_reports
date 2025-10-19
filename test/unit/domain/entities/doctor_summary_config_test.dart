import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/doctor_summary_config.dart';

void main() {
  group('DoctorSummaryConfig', () {
    final tStartDate = DateTime(2025, 1, 1);
    final tEndDate = DateTime(2025, 12, 31);
    const tSelectedReportIds = ['report-1', 'report-2'];
    const tIncludeVitals = true;
    const tIncludeFullDataTable = false;

    test('should create a valid DoctorSummaryConfig with all fields', () {
      // Act
      final config = DoctorSummaryConfig(
        startDate: tStartDate,
        endDate: tEndDate,
        selectedReportIds: tSelectedReportIds,
        includeVitals: tIncludeVitals,
        includeFullDataTable: tIncludeFullDataTable,
      );

      // Assert
      expect(config.startDate, tStartDate);
      expect(config.endDate, tEndDate);
      expect(config.selectedReportIds, tSelectedReportIds);
      expect(config.includeVitals, tIncludeVitals);
      expect(config.includeFullDataTable, tIncludeFullDataTable);
    });

    test('should create with empty selectedReportIds for all reports', () {
      // Act
      final config = DoctorSummaryConfig(
        startDate: tStartDate,
        endDate: tEndDate,
        selectedReportIds: const [],
        includeVitals: tIncludeVitals,
        includeFullDataTable: tIncludeFullDataTable,
      );

      // Assert
      expect(config.selectedReportIds, isEmpty);
    });

    test('should create with default includeVitals as true', () {
      // Act
      final config = DoctorSummaryConfig(
        startDate: tStartDate,
        endDate: tEndDate,
        selectedReportIds: tSelectedReportIds,
        includeVitals: true,
        includeFullDataTable: tIncludeFullDataTable,
      );

      // Assert
      expect(config.includeVitals, true);
    });

    test('should create with default includeFullDataTable as false', () {
      // Act
      final config = DoctorSummaryConfig(
        startDate: tStartDate,
        endDate: tEndDate,
        selectedReportIds: tSelectedReportIds,
        includeVitals: tIncludeVitals,
        includeFullDataTable: false,
      );

      // Assert
      expect(config.includeFullDataTable, false);
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      final config1 = DoctorSummaryConfig(
        startDate: tStartDate,
        endDate: tEndDate,
        selectedReportIds: tSelectedReportIds,
        includeVitals: tIncludeVitals,
        includeFullDataTable: tIncludeFullDataTable,
      );
      final config2 = DoctorSummaryConfig(
        startDate: tStartDate,
        endDate: tEndDate,
        selectedReportIds: tSelectedReportIds,
        includeVitals: tIncludeVitals,
        includeFullDataTable: tIncludeFullDataTable,
      );

      // Assert
      expect(config1, config2);
    });

    test('should not be equal when properties are different', () {
      // Arrange
      final config1 = DoctorSummaryConfig(
        startDate: tStartDate,
        endDate: tEndDate,
        selectedReportIds: tSelectedReportIds,
        includeVitals: tIncludeVitals,
        includeFullDataTable: tIncludeFullDataTable,
      );
      final config2 = DoctorSummaryConfig(
        startDate: tStartDate,
        endDate: DateTime(2026, 12, 31), // Different end date
        selectedReportIds: tSelectedReportIds,
        includeVitals: tIncludeVitals,
        includeFullDataTable: tIncludeFullDataTable,
      );

      // Assert
      expect(config1, isNot(config2));
    });

    test('should have correct props for Equatable', () {
      // Arrange
      final config = DoctorSummaryConfig(
        startDate: tStartDate,
        endDate: tEndDate,
        selectedReportIds: tSelectedReportIds,
        includeVitals: tIncludeVitals,
        includeFullDataTable: tIncludeFullDataTable,
      );

      // Assert
      expect(
        config.props,
        [
          tStartDate,
          tEndDate,
          tSelectedReportIds,
          tIncludeVitals,
          tIncludeFullDataTable,
        ],
      );
    });

    group('copyWith', () {
      final originalConfig = DoctorSummaryConfig(
        startDate: tStartDate,
        endDate: tEndDate,
        selectedReportIds: tSelectedReportIds,
        includeVitals: tIncludeVitals,
        includeFullDataTable: tIncludeFullDataTable,
      );

      test('should return a copy with updated startDate', () {
        // Arrange
        final newStartDate = DateTime(2025, 6, 1);

        // Act
        final updated = originalConfig.copyWith(startDate: newStartDate);

        // Assert
        expect(updated.startDate, newStartDate);
        expect(updated.endDate, tEndDate);
        expect(updated.selectedReportIds, tSelectedReportIds);
      });

      test('should return a copy with updated endDate', () {
        // Arrange
        final newEndDate = DateTime(2026, 6, 1);

        // Act
        final updated = originalConfig.copyWith(endDate: newEndDate);

        // Assert
        expect(updated.startDate, tStartDate);
        expect(updated.endDate, newEndDate);
        expect(updated.selectedReportIds, tSelectedReportIds);
      });

      test('should return a copy with updated selectedReportIds', () {
        // Arrange
        const newReportIds = ['report-3', 'report-4'];

        // Act
        final updated = originalConfig.copyWith(selectedReportIds: newReportIds);

        // Assert
        expect(updated.selectedReportIds, newReportIds);
        expect(updated.startDate, tStartDate);
        expect(updated.endDate, tEndDate);
      });

      test('should return a copy with updated includeVitals', () {
        // Act
        final updated = originalConfig.copyWith(includeVitals: false);

        // Assert
        expect(updated.includeVitals, false);
        expect(updated.startDate, tStartDate);
      });

      test('should return a copy with updated includeFullDataTable', () {
        // Act
        final updated = originalConfig.copyWith(includeFullDataTable: true);

        // Assert
        expect(updated.includeFullDataTable, true);
        expect(updated.startDate, tStartDate);
      });

      test('should return exact copy when no parameters provided', () {
        // Act
        final copy = originalConfig.copyWith();

        // Assert
        expect(copy, originalConfig);
      });
    });

    group('validation', () {
      test('should throw assertion error when startDate is after endDate', () {
        // Arrange
        final invalidStartDate = DateTime(2025, 12, 31);
        final invalidEndDate = DateTime(2025, 1, 1);

        // Act & Assert
        expect(
          () => DoctorSummaryConfig(
            startDate: invalidStartDate,
            endDate: invalidEndDate,
            selectedReportIds: tSelectedReportIds,
            includeVitals: tIncludeVitals,
            includeFullDataTable: tIncludeFullDataTable,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should allow startDate equal to endDate', () {
        // Arrange
        final sameDate = DateTime(2025, 6, 1);

        // Act
        final config = DoctorSummaryConfig(
          startDate: sameDate,
          endDate: sameDate,
          selectedReportIds: tSelectedReportIds,
          includeVitals: tIncludeVitals,
          includeFullDataTable: tIncludeFullDataTable,
        );

        // Assert
        expect(config.startDate, sameDate);
        expect(config.endDate, sameDate);
      });
    });
  });
}
