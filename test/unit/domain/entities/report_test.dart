import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/health_entry.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';

void main() {
  group('Report', () {
    const tId = 'report-123';
    final tDate = DateTime(2025, 10, 15);
    const tLabName = 'City Lab';
    final tCreatedAt = DateTime(2025, 10, 15, 10, 30);
    final tUpdatedAt = DateTime(2025, 10, 15, 10, 30);
    const tOriginalFilePath = '/path/to/report.pdf';
    const tNotes = 'Annual checkup';

    // Helper biomarkers
    final tBiomarker1 = Biomarker(
      id: 'bio-1',
      name: 'Hemoglobin',
      value: 15.0,
      unit: 'g/dL',
      referenceRange: const ReferenceRange(min: 13.0, max: 17.0),
      measuredAt: tDate,
    );

    final tBiomarker2 = Biomarker(
      id: 'bio-2',
      name: 'Glucose',
      value: 110.0, // High (out of range)
      unit: 'mg/dL',
      referenceRange: const ReferenceRange(min: 70.0, max: 100.0),
      measuredAt: tDate,
    );

    final tBiomarker3 = Biomarker(
      id: 'bio-3',
      name: 'Cholesterol',
      value: 160.0,
      unit: 'mg/dL',
      referenceRange: const ReferenceRange(min: 125.0, max: 200.0),
      measuredAt: tDate,
    );

    final tBiomarker4 = Biomarker(
      id: 'bio-4',
      name: 'Iron',
      value: 40.0, // Low (out of range)
      unit: 'μg/dL',
      referenceRange: const ReferenceRange(min: 60.0, max: 170.0),
      measuredAt: tDate,
    );

    final tBiomarkers = [tBiomarker1, tBiomarker2, tBiomarker3, tBiomarker4];

    test('should create a valid Report with all fields', () {
      // Act
      final report = Report(
        id: tId,
        date: tDate,
        labName: tLabName,
        biomarkers: tBiomarkers,
        originalFilePath: tOriginalFilePath,
        notes: tNotes,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );

      // Assert
      expect(report.id, tId);
      expect(report.date, tDate);
      expect(report.labName, tLabName);
      expect(report.biomarkers, tBiomarkers);
      expect(report.originalFilePath, tOriginalFilePath);
      expect(report.notes, tNotes);
      expect(report.createdAt, tCreatedAt);
      expect(report.updatedAt, tUpdatedAt);
    });

    test('should create a Report with minimal fields (no notes)', () {
      // Act
      final report = Report(
        id: tId,
        date: tDate,
        labName: tLabName,
        biomarkers: tBiomarkers,
        originalFilePath: tOriginalFilePath,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );

      // Assert
      expect(report.id, tId);
      expect(report.notes, isNull);
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      final report1 = Report(
        id: tId,
        date: tDate,
        labName: tLabName,
        biomarkers: tBiomarkers,
        originalFilePath: tOriginalFilePath,
        notes: tNotes,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );
      final report2 = Report(
        id: tId,
        date: tDate,
        labName: tLabName,
        biomarkers: tBiomarkers,
        originalFilePath: tOriginalFilePath,
        notes: tNotes,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );

      // Assert
      expect(report1, report2);
    });

    test('should not be equal when properties are different', () {
      // Arrange
      final report1 = Report(
        id: tId,
        date: tDate,
        labName: tLabName,
        biomarkers: tBiomarkers,
        originalFilePath: tOriginalFilePath,
        notes: tNotes,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );
      final report2 = Report(
        id: 'different-id',
        date: tDate,
        labName: tLabName,
        biomarkers: tBiomarkers,
        originalFilePath: tOriginalFilePath,
        notes: tNotes,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );

      // Assert
      expect(report1, isNot(report2));
    });

    group('outOfRangeBiomarkers getter', () {
      test('should return biomarkers that are out of range', () {
        // Arrange
        final report = Report(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: tBiomarkers,
          originalFilePath: tOriginalFilePath,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Act
        final outOfRange = report.outOfRangeBiomarkers;

        // Assert
        expect(outOfRange.length, 2);
        expect(outOfRange, contains(tBiomarker2)); // Glucose (high)
        expect(outOfRange, contains(tBiomarker4)); // Iron (low)
      });

      test('should return empty list when all biomarkers are in range', () {
        // Arrange
        final normalBiomarkers = [tBiomarker1, tBiomarker3];
        final report = Report(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: normalBiomarkers,
          originalFilePath: tOriginalFilePath,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Act
        final outOfRange = report.outOfRangeBiomarkers;

        // Assert
        expect(outOfRange, isEmpty);
      });

      test('should return empty list when report has no biomarkers', () {
        // Arrange
        final report = Report(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: const [],
          originalFilePath: tOriginalFilePath,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Act
        final outOfRange = report.outOfRangeBiomarkers;

        // Assert
        expect(outOfRange, isEmpty);
      });
    });

    group('hasOutOfRangeBiomarkers getter', () {
      test('should return true when report has out of range biomarkers', () {
        // Arrange
        final report = Report(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: tBiomarkers,
          originalFilePath: tOriginalFilePath,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(report.hasOutOfRangeBiomarkers, true);
      });

      test('should return false when all biomarkers are in range', () {
        // Arrange
        final normalBiomarkers = [tBiomarker1, tBiomarker3];
        final report = Report(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: normalBiomarkers,
          originalFilePath: tOriginalFilePath,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(report.hasOutOfRangeBiomarkers, false);
      });

      test('should return false when report has no biomarkers', () {
        // Arrange
        final report = Report(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: const [],
          originalFilePath: tOriginalFilePath,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(report.hasOutOfRangeBiomarkers, false);
      });
    });

    group('outOfRangeCount getter', () {
      test('should return count of out of range biomarkers', () {
        // Arrange
        final report = Report(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: tBiomarkers,
          originalFilePath: tOriginalFilePath,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(report.outOfRangeCount, 2);
      });

      test('should return 0 when all biomarkers are in range', () {
        // Arrange
        final normalBiomarkers = [tBiomarker1, tBiomarker3];
        final report = Report(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: normalBiomarkers,
          originalFilePath: tOriginalFilePath,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(report.outOfRangeCount, 0);
      });

      test('should return 0 when report has no biomarkers', () {
        // Arrange
        final report = Report(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: const [],
          originalFilePath: tOriginalFilePath,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(report.outOfRangeCount, 0);
      });
    });

    group('totalBiomarkerCount getter', () {
      test('should return total count of biomarkers', () {
        // Arrange
        final report = Report(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: tBiomarkers,
          originalFilePath: tOriginalFilePath,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(report.totalBiomarkerCount, 4);
      });

      test('should return 0 when report has no biomarkers', () {
        // Arrange
        final report = Report(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: const [],
          originalFilePath: tOriginalFilePath,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(report.totalBiomarkerCount, 0);
      });
    });

    group('copyWith', () {
      final originalReport = Report(
        id: tId,
        date: tDate,
        labName: tLabName,
        biomarkers: tBiomarkers,
        originalFilePath: tOriginalFilePath,
        notes: tNotes,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );

      test('should return a copy with updated id', () {
        // Act
        final updated = originalReport.copyWith(id: 'new-id');

        // Assert
        expect(updated.id, 'new-id');
        expect(updated.date, tDate);
        expect(updated.labName, tLabName);
        expect(updated.biomarkers, tBiomarkers);
      });

      test('should return a copy with updated date', () {
        // Arrange
        final newDate = DateTime(2025, 11, 15);

        // Act
        final updated = originalReport.copyWith(date: newDate);

        // Assert
        expect(updated.date, newDate);
        expect(updated.id, tId);
        expect(updated.labName, tLabName);
      });

      test('should return a copy with updated labName', () {
        // Act
        final updated = originalReport.copyWith(labName: 'New Lab');

        // Assert
        expect(updated.labName, 'New Lab');
        expect(updated.id, tId);
        expect(updated.date, tDate);
      });

      test('should return a copy with updated biomarkers', () {
        // Arrange
        final newBiomarkers = [tBiomarker1];

        // Act
        final updated = originalReport.copyWith(biomarkers: newBiomarkers);

        // Assert
        expect(updated.biomarkers, newBiomarkers);
        expect(updated.biomarkers.length, 1);
        expect(updated.id, tId);
      });

      test('should return a copy with updated originalFilePath', () {
        // Act
        final updated = originalReport.copyWith(
          originalFilePath: '/new/path.pdf',
        );

        // Assert
        expect(updated.originalFilePath, '/new/path.pdf');
        expect(updated.id, tId);
      });

      test('should return a copy with updated notes', () {
        // Act
        final updated = originalReport.copyWith(notes: 'New notes');

        // Assert
        expect(updated.notes, 'New notes');
        expect(updated.id, tId);
      });

      test('should return a copy with updated createdAt', () {
        // Arrange
        final newCreatedAt = DateTime(2025, 11, 15, 14, 30);

        // Act
        final updated = originalReport.copyWith(createdAt: newCreatedAt);

        // Assert
        expect(updated.createdAt, newCreatedAt);
        expect(updated.id, tId);
      });

      test('should return a copy with updated updatedAt', () {
        // Arrange
        final newUpdatedAt = DateTime(2025, 11, 15, 15, 30);

        // Act
        final updated = originalReport.copyWith(updatedAt: newUpdatedAt);

        // Assert
        expect(updated.updatedAt, newUpdatedAt);
        expect(updated.id, tId);
      });

      test('should return exact copy when no parameters provided', () {
        // Act
        final copy = originalReport.copyWith();

        // Assert
        expect(copy, originalReport);
      });

      test('should return a copy with multiple fields updated', () {
        // Arrange
        final newDate = DateTime(2025, 12, 15);
        final newUpdatedAt = DateTime(2025, 12, 15, 10, 30);

        // Act
        final updated = originalReport.copyWith(
          labName: 'Updated Lab',
          date: newDate,
          notes: 'Updated notes',
          updatedAt: newUpdatedAt,
        );

        // Assert
        expect(updated.labName, 'Updated Lab');
        expect(updated.date, newDate);
        expect(updated.notes, 'Updated notes');
        expect(updated.updatedAt, newUpdatedAt);
        expect(updated.id, tId);
        expect(updated.biomarkers, tBiomarkers);
      });
    });

    test('should have correct props for Equatable', () {
      // Arrange
      final report = Report(
        id: tId,
        date: tDate,
        labName: tLabName,
        biomarkers: tBiomarkers,
        originalFilePath: tOriginalFilePath,
        notes: tNotes,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );

      // Assert
      expect(
        report.props,
        [
          tId,
          tDate,
          tLabName,
          tBiomarkers,
          tOriginalFilePath,
          tNotes,
          tCreatedAt,
          tUpdatedAt,
        ],
      );
    });

    group('HealthEntry interface', () {
      final report = Report(
        id: tId,
        date: tDate,
        labName: tLabName,
        biomarkers: tBiomarkers,
        originalFilePath: tOriginalFilePath,
        notes: tNotes,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );

      test('should implement HealthEntry', () {
        // Assert
        expect(report, isA<HealthEntry>());
      });

      test('should return HealthEntryType.labReport for entryType getter', () {
        // Assert
        expect(report.entryType, HealthEntryType.labReport);
      });

      test('should return date field for timestamp getter', () {
        // Assert
        expect(report.timestamp, tDate);
      });

      test('should return "Lab Report" for displayTitle getter', () {
        // Assert
        expect(report.displayTitle, 'Lab Report');
      });

      test('should return correct format for displaySubtitle getter', () {
        // Assert
        expect(report.displaySubtitle, '$tLabName • ${tBiomarkers.length} biomarkers');
        expect(report.displaySubtitle, 'City Lab • 4 biomarkers');
      });

      test('should return same as hasOutOfRangeBiomarkers for hasWarnings getter', () {
        // Assert
        expect(report.hasWarnings, report.hasOutOfRangeBiomarkers);
        expect(report.hasWarnings, true); // tBiomarkers has 2 out of range
      });

      test('should return false for hasWarnings when all biomarkers are in range', () {
        // Arrange
        final normalBiomarkers = [tBiomarker1, tBiomarker3];
        final normalReport = Report(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: normalBiomarkers,
          originalFilePath: tOriginalFilePath,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(normalReport.hasWarnings, false);
        expect(normalReport.hasOutOfRangeBiomarkers, false);
      });
    });
  });
}
