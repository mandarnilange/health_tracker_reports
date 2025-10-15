import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/models/biomarker_model.dart';
import 'package:health_tracker_reports/data/models/reference_range_model.dart';
import 'package:health_tracker_reports/data/models/report_model.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';

void main() {
  group('ReportModel', () {
    const tId = 'report-123';
    final tDate = DateTime(2025, 10, 15);
    const tLabName = 'Quest Diagnostics';
    const tOriginalFilePath = '/path/to/report.pdf';
    const tNotes = 'Test notes';
    final tCreatedAt = DateTime(2025, 10, 15, 10, 0);
    final tUpdatedAt = DateTime(2025, 10, 15, 11, 0);

    final tBiomarker1 = Biomarker(
      id: 'bio-1',
      name: 'Hemoglobin',
      value: 14.5,
      unit: 'g/dL',
      referenceRange: const ReferenceRange(min: 12.0, max: 16.0),
      measuredAt: DateTime(2025, 10, 15, 9, 0),
    );

    final tBiomarker2 = Biomarker(
      id: 'bio-2',
      name: 'Glucose',
      value: 95.0,
      unit: 'mg/dL',
      referenceRange: const ReferenceRange(min: 70.0, max: 100.0),
      measuredAt: DateTime(2025, 10, 15, 9, 0),
    );

    final tBiomarkers = [tBiomarker1, tBiomarker2];

    final tReport = Report(
      id: tId,
      date: tDate,
      labName: tLabName,
      biomarkers: tBiomarkers,
      originalFilePath: tOriginalFilePath,
      notes: tNotes,
      createdAt: tCreatedAt,
      updatedAt: tUpdatedAt,
    );

    final tBiomarkerModels = [
      BiomarkerModel(
        id: 'bio-1',
        name: 'Hemoglobin',
        value: 14.5,
        unit: 'g/dL',
        referenceRange: const ReferenceRangeModel(min: 12.0, max: 16.0),
        measuredAt: DateTime(2025, 10, 15, 9, 0),
      ),
      BiomarkerModel(
        id: 'bio-2',
        name: 'Glucose',
        value: 95.0,
        unit: 'mg/dL',
        referenceRange: const ReferenceRangeModel(min: 70.0, max: 100.0),
        measuredAt: DateTime(2025, 10, 15, 9, 0),
      ),
    ];

    final tReportModel = ReportModel(
      id: tId,
      date: tDate,
      labName: tLabName,
      biomarkers: tBiomarkerModels,
      originalFilePath: tOriginalFilePath,
      notes: tNotes,
      createdAt: tCreatedAt,
      updatedAt: tUpdatedAt,
    );

    final tJson = {
      'id': tId,
      'date': tDate.toIso8601String(),
      'labName': tLabName,
      'biomarkers': [
        {
          'id': 'bio-1',
          'name': 'Hemoglobin',
          'value': 14.5,
          'unit': 'g/dL',
          'referenceRange': {'min': 12.0, 'max': 16.0},
          'measuredAt': DateTime(2025, 10, 15, 9, 0).toIso8601String(),
        },
        {
          'id': 'bio-2',
          'name': 'Glucose',
          'value': 95.0,
          'unit': 'mg/dL',
          'referenceRange': {'min': 70.0, 'max': 100.0},
          'measuredAt': DateTime(2025, 10, 15, 9, 0).toIso8601String(),
        },
      ],
      'originalFilePath': tOriginalFilePath,
      'notes': tNotes,
      'createdAt': tCreatedAt.toIso8601String(),
      'updatedAt': tUpdatedAt.toIso8601String(),
    };

    group('fromEntity', () {
      test('should create ReportModel from Report entity', () {
        // Act
        final result = ReportModel.fromEntity(tReport);

        // Assert
        expect(result, isA<ReportModel>());
        expect(result.id, tReport.id);
        expect(result.date, tReport.date);
        expect(result.labName, tReport.labName);
        expect(result.biomarkers.length, tReport.biomarkers.length);
        expect(result.originalFilePath, tReport.originalFilePath);
        expect(result.notes, tReport.notes);
        expect(result.createdAt, tReport.createdAt);
        expect(result.updatedAt, tReport.updatedAt);
      });

      test('should convert biomarkers to BiomarkerModels', () {
        // Act
        final result = ReportModel.fromEntity(tReport);

        // Assert
        expect(result.biomarkers, isA<List<Biomarker>>());
        expect(result.biomarkers[0], isA<BiomarkerModel>());
        expect(result.biomarkers[1], isA<BiomarkerModel>());
      });

      test('should create model that equals another model with same values', () {
        // Act
        final result = ReportModel.fromEntity(tReport);

        // Assert
        expect(result, tReportModel);
      });

      test('should handle report with no notes', () {
        // Arrange
        final reportWithoutNotes = Report(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: tBiomarkers,
          originalFilePath: tOriginalFilePath,
          notes: null,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Act
        final result = ReportModel.fromEntity(reportWithoutNotes);

        // Assert
        expect(result.notes, isNull);
      });

      test('should handle report with empty biomarkers list', () {
        // Arrange
        final reportWithNoBiomarkers = Report(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: const [],
          originalFilePath: tOriginalFilePath,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Act
        final result = ReportModel.fromEntity(reportWithNoBiomarkers);

        // Assert
        expect(result.biomarkers, isEmpty);
      });

      test('should inherit getters from Report entity', () {
        // Act
        final result = ReportModel.fromEntity(tReport);

        // Assert
        expect(result.totalBiomarkerCount, 2);
        expect(result.hasOutOfRangeBiomarkers, false);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // Act
        final result = tReportModel.toJson();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result, tJson);
      });

      test('should return JSON with correct keys', () {
        // Act
        final result = tReportModel.toJson();

        // Assert
        expect(result.containsKey('id'), true);
        expect(result.containsKey('date'), true);
        expect(result.containsKey('labName'), true);
        expect(result.containsKey('biomarkers'), true);
        expect(result.containsKey('originalFilePath'), true);
        expect(result.containsKey('notes'), true);
        expect(result.containsKey('createdAt'), true);
        expect(result.containsKey('updatedAt'), true);
        expect(result.keys.length, 8);
      });

      test('should serialize biomarkers as list of JSON objects', () {
        // Act
        final result = tReportModel.toJson();

        // Assert
        expect(result['biomarkers'], isA<List>());
        expect(result['biomarkers'].length, 2);
        expect(result['biomarkers'][0], isA<Map<String, dynamic>>());
        expect(result['biomarkers'][0]['id'], 'bio-1');
        expect(result['biomarkers'][1]['id'], 'bio-2');
      });

      test('should serialize date fields as ISO8601 strings', () {
        // Act
        final result = tReportModel.toJson();

        // Assert
        expect(result['date'], isA<String>());
        expect(result['date'], tDate.toIso8601String());
        expect(result['createdAt'], tCreatedAt.toIso8601String());
        expect(result['updatedAt'], tUpdatedAt.toIso8601String());
      });

      test('should handle null notes', () {
        // Arrange
        final modelWithoutNotes = ReportModel(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: tBiomarkerModels,
          originalFilePath: tOriginalFilePath,
          notes: null,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Act
        final result = modelWithoutNotes.toJson();

        // Assert
        expect(result['notes'], isNull);
      });

      test('should handle empty biomarkers list', () {
        // Arrange
        final modelWithNoBiomarkers = ReportModel(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: const [],
          originalFilePath: tOriginalFilePath,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Act
        final result = modelWithNoBiomarkers.toJson();

        // Assert
        expect(result['biomarkers'], isA<List>());
        expect(result['biomarkers'], isEmpty);
      });
    });

    group('fromJson', () {
      test('should return a valid ReportModel from JSON', () {
        // Act
        final result = ReportModel.fromJson(tJson);

        // Assert
        expect(result, isA<ReportModel>());
        expect(result, tReportModel);
      });

      test('should correctly parse all fields from JSON', () {
        // Act
        final result = ReportModel.fromJson(tJson);

        // Assert
        expect(result.id, tId);
        expect(result.date, tDate);
        expect(result.labName, tLabName);
        expect(result.biomarkers.length, 2);
        expect(result.originalFilePath, tOriginalFilePath);
        expect(result.notes, tNotes);
        expect(result.createdAt, tCreatedAt);
        expect(result.updatedAt, tUpdatedAt);
      });

      test('should parse biomarkers list from JSON', () {
        // Act
        final result = ReportModel.fromJson(tJson);

        // Assert
        expect(result.biomarkers, isA<List<Biomarker>>());
        expect(result.biomarkers[0], isA<BiomarkerModel>());
        expect(result.biomarkers[0].id, 'bio-1');
        expect(result.biomarkers[0].name, 'Hemoglobin');
        expect(result.biomarkers[1].id, 'bio-2');
        expect(result.biomarkers[1].name, 'Glucose');
      });

      test('should parse date fields from ISO8601 strings', () {
        // Act
        final result = ReportModel.fromJson(tJson);

        // Assert
        expect(result.date, isA<DateTime>());
        expect(result.date, tDate);
        expect(result.createdAt, tCreatedAt);
        expect(result.updatedAt, tUpdatedAt);
      });

      test('should handle null notes from JSON', () {
        // Arrange
        final jsonWithoutNotes = {...tJson, 'notes': null};

        // Act
        final result = ReportModel.fromJson(jsonWithoutNotes);

        // Assert
        expect(result.notes, isNull);
      });

      test('should handle empty biomarkers list from JSON', () {
        // Arrange
        final jsonWithNoBiomarkers = {...tJson, 'biomarkers': []};

        // Act
        final result = ReportModel.fromJson(jsonWithNoBiomarkers);

        // Assert
        expect(result.biomarkers, isEmpty);
      });

      test('should parse biomarkers with nested data correctly', () {
        // Act
        final result = ReportModel.fromJson(tJson);

        // Assert
        final biomarker = result.biomarkers[0];
        expect(biomarker.referenceRange.min, 12.0);
        expect(biomarker.referenceRange.max, 16.0);
        expect(biomarker.measuredAt, DateTime(2025, 10, 15, 9, 0));
      });
    });

    group('JSON serialization round-trip', () {
      test('should preserve all data through toJson and fromJson', () {
        // Act
        final json = tReportModel.toJson();
        final result = ReportModel.fromJson(json);

        // Assert
        expect(result, tReportModel);
      });

      test('should preserve biomarkers list through round-trip', () {
        // Act
        final json = tReportModel.toJson();
        final result = ReportModel.fromJson(json);

        // Assert
        expect(result.biomarkers.length, tReportModel.biomarkers.length);
        expect(result.biomarkers[0], tReportModel.biomarkers[0]);
        expect(result.biomarkers[1], tReportModel.biomarkers[1]);
      });

      test('should preserve null notes through round-trip', () {
        // Arrange
        final modelWithoutNotes = ReportModel(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: tBiomarkerModels,
          originalFilePath: tOriginalFilePath,
          notes: null,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Act
        final json = modelWithoutNotes.toJson();
        final result = ReportModel.fromJson(json);

        // Assert
        expect(result.notes, isNull);
      });

      test('should preserve empty biomarkers list through round-trip', () {
        // Arrange
        final modelWithNoBiomarkers = ReportModel(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: const [],
          originalFilePath: tOriginalFilePath,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Act
        final json = modelWithNoBiomarkers.toJson();
        final result = ReportModel.fromJson(json);

        // Assert
        expect(result.biomarkers, isEmpty);
      });

      test('should preserve DateTime precision through round-trip', () {
        // Arrange
        final specificDate = DateTime(2025, 3, 15, 14, 30, 45, 123);
        final model = ReportModel(
          id: tId,
          date: specificDate,
          labName: tLabName,
          biomarkers: tBiomarkerModels,
          originalFilePath: tOriginalFilePath,
          notes: tNotes,
          createdAt: specificDate,
          updatedAt: specificDate,
        );

        // Act
        final json = model.toJson();
        final result = ReportModel.fromJson(json);

        // Assert
        expect(result.date.year, specificDate.year);
        expect(result.date.month, specificDate.month);
        expect(result.date.day, specificDate.day);
        expect(result.date.hour, specificDate.hour);
        expect(result.date.minute, specificDate.minute);
        expect(result.date.second, specificDate.second);
      });
    });

    group('inheritance from Report', () {
      test('should be a subtype of Report', () {
        // Assert
        expect(tReportModel, isA<Report>());
      });

      test('should have access to outOfRangeBiomarkers getter', () {
        // Arrange - create a model with out-of-range biomarker
        final outOfRangeBiomarker = BiomarkerModel(
          id: 'bio-3',
          name: 'Cholesterol',
          value: 250.0,
          unit: 'mg/dL',
          referenceRange: const ReferenceRangeModel(min: 100.0, max: 200.0),
          measuredAt: DateTime(2025, 10, 15, 9, 0),
        );

        final modelWithOutOfRange = ReportModel(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: [tBiomarkerModels[0], outOfRangeBiomarker],
          originalFilePath: tOriginalFilePath,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(modelWithOutOfRange.outOfRangeBiomarkers.length, 1);
        expect(modelWithOutOfRange.outOfRangeBiomarkers[0].name, 'Cholesterol');
      });

      test('should have access to hasOutOfRangeBiomarkers getter', () {
        // Arrange
        final normalModel = ReportModel(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: tBiomarkerModels,
          originalFilePath: tOriginalFilePath,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        final outOfRangeBiomarker = BiomarkerModel(
          id: 'bio-3',
          name: 'Cholesterol',
          value: 250.0,
          unit: 'mg/dL',
          referenceRange: const ReferenceRangeModel(min: 100.0, max: 200.0),
          measuredAt: DateTime(2025, 10, 15, 9, 0),
        );

        final modelWithOutOfRange = ReportModel(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: [outOfRangeBiomarker],
          originalFilePath: tOriginalFilePath,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(normalModel.hasOutOfRangeBiomarkers, false);
        expect(modelWithOutOfRange.hasOutOfRangeBiomarkers, true);
      });

      test('should have access to outOfRangeCount getter', () {
        // Arrange
        final outOfRangeBiomarker1 = BiomarkerModel(
          id: 'bio-3',
          name: 'Cholesterol',
          value: 250.0,
          unit: 'mg/dL',
          referenceRange: const ReferenceRangeModel(min: 100.0, max: 200.0),
          measuredAt: DateTime(2025, 10, 15, 9, 0),
        );

        final outOfRangeBiomarker2 = BiomarkerModel(
          id: 'bio-4',
          name: 'Triglycerides',
          value: 300.0,
          unit: 'mg/dL',
          referenceRange: const ReferenceRangeModel(min: 50.0, max: 150.0),
          measuredAt: DateTime(2025, 10, 15, 9, 0),
        );

        final model = ReportModel(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: [tBiomarkerModels[0], outOfRangeBiomarker1, outOfRangeBiomarker2],
          originalFilePath: tOriginalFilePath,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(model.outOfRangeCount, 2);
      });

      test('should have access to totalBiomarkerCount getter', () {
        // Assert
        expect(tReportModel.totalBiomarkerCount, 2);
      });

      test('should maintain Equatable equality', () {
        // Arrange
        final model1 = ReportModel(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: tBiomarkerModels,
          originalFilePath: tOriginalFilePath,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        final model2 = ReportModel(
          id: tId,
          date: tDate,
          labName: tLabName,
          biomarkers: tBiomarkerModels,
          originalFilePath: tOriginalFilePath,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        final model3 = ReportModel(
          id: 'different-id',
          date: tDate,
          labName: tLabName,
          biomarkers: tBiomarkerModels,
          originalFilePath: tOriginalFilePath,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(model1, model2);
        expect(model1, isNot(model3));
      });

      test('should have access to copyWith method', () {
        // Act
        final result = tReportModel.copyWith(labName: 'Different Lab');

        // Assert
        expect(result.labName, 'Different Lab');
        expect(result.id, tId);
        expect(result.date, tDate);
      });
    });
  });
}
