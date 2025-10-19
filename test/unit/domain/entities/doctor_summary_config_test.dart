import 'package:flutter_test/flutter_test.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_reports/domain/entities/doctor_summary_config.dart';

void main() {
  group('DoctorSummaryConfig', () {
    final startDate = DateTime(2023, 1, 1);
    final endDate = DateTime(2023, 1, 31);
    
    // A base model instance to use in tests
    final tDoctorSummaryConfig = DoctorSummaryConfig(
      startDate: startDate,
      endDate: endDate,
      selectedReportIds: const ['report1', 'report2'],
      includeVitals: true,
      includeFullDataTable: false,
    );

    test('DoctorSummaryConfig should be a subclass of Equatable', () {
      expect(tDoctorSummaryConfig, isA<Equatable>());
    });

    test('should correctly initialize properties', () {
      // Assert
      expect(tDoctorSummaryConfig.startDate, startDate);
      expect(tDoctorSummaryConfig.endDate, endDate);
      expect(tDoctorSummaryConfig.selectedReportIds, const ['report1', 'report2']);
      expect(tDoctorSummaryConfig.includeVitals, isTrue);
      expect(tDoctorSummaryConfig.includeFullDataTable, isFalse);
    });

    test('props list should contain all properties', () {
      // Assert
      expect(tDoctorSummaryConfig.props, [
        startDate,
        endDate,
        const ['report1', 'report2'],
        true,
        false,
      ]);
    });

    group('copyWith', () {
      test('should return a new instance with the updated startDate', () {
        final newDate = DateTime(2023, 2, 1);
        final updatedConfig = tDoctorSummaryConfig.copyWith(startDate: newDate);
        expect(updatedConfig.startDate, newDate);
        expect(updatedConfig.endDate, tDoctorSummaryConfig.endDate);
      });

      test('should return a new instance with the updated endDate', () {
        final newDate = DateTime(2023, 2, 28);
        final updatedConfig = tDoctorSummaryConfig.copyWith(endDate: newDate);
        expect(updatedConfig.endDate, newDate);
        expect(updatedConfig.startDate, tDoctorSummaryConfig.startDate);
      });

      test('should return a new instance with updated selectedReportIds', () {
        final newIds = ['report3'];
        final updatedConfig = tDoctorSummaryConfig.copyWith(selectedReportIds: newIds);
        expect(updatedConfig.selectedReportIds, newIds);
      });

      test('should return a new instance with updated includeVitals', () {
        final updatedConfig = tDoctorSummaryConfig.copyWith(includeVitals: false);
        expect(updatedConfig.includeVitals, isFalse);
      });

      test('should return a new instance with updated includeFullDataTable', () {
        final updatedConfig = tDoctorSummaryConfig.copyWith(includeFullDataTable: true);
        expect(updatedConfig.includeFullDataTable, isTrue);
      });

      test('should return an identical instance if copyWith is called with no arguments', () {
        final updatedConfig = tDoctorSummaryConfig.copyWith();
        expect(updatedConfig, equals(tDoctorSummaryConfig));
      });

      test('should return a new instance with multiple updated fields', () {
        final newDate = DateTime(2024, 1, 1);
        final newIds = ['report_new'];
        final updatedConfig = tDoctorSummaryConfig.copyWith(
          startDate: newDate,
          selectedReportIds: newIds,
          includeVitals: false,
        );
        expect(updatedConfig.startDate, newDate);
        expect(updatedConfig.selectedReportIds, newIds);
        expect(updatedConfig.includeVitals, isFalse);
        expect(updatedConfig.endDate, tDoctorSummaryConfig.endDate);
      });
    });
  });
}