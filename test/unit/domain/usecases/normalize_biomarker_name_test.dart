import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/usecases/normalize_biomarker_name.dart';

void main() {
  late NormalizeBiomarkerName usecase;

  setUp(() {
    usecase = NormalizeBiomarkerName();
  });

  group('NormalizeBiomarkerName', () {
    test('should normalize "Na" to "Sodium"', () {
      // Act
      final result = usecase('Na');

      // Assert
      expect(result, 'Sodium');
    });

    test('should normalize variations of a biomarker name', () {
      // Act
      final result1 = usecase('NA');
      final result2 = usecase('na');
      final result3 = usecase('Na+');
      final result4 = usecase('SODIUM');

      // Assert
      expect(result1, 'Sodium');
      expect(result2, 'Sodium');
      expect(result3, 'Sodium');
      expect(result4, 'Sodium');
    });

    test('should return the same name if no normalization is found', () {
      // Act
      final result = usecase('UnknownBiomarker');

      // Assert
      expect(result, 'UnknownBiomarker');
    });

    test('should return an empty string for empty or null input', () {
      // Act
      final result1 = usecase('');
      final result2 = usecase(null);

      // Assert
      expect(result1, '');
      expect(result2, '');
    });

    group('Lipid Panel', () {
      test('should normalize cholesterol variations to "Total Cholesterol"', () {
        // Act & Assert
        expect(usecase('CHOL'), 'Total Cholesterol');
        expect(usecase('chol'), 'Total Cholesterol');
        expect(usecase('TC'), 'Total Cholesterol');
        expect(usecase('Total Cholesterol'), 'Total Cholesterol');
        expect(usecase('TOTAL CHOLESTEROL'), 'Total Cholesterol');
      });

      test('should normalize LDL variations to "LDL Cholesterol"', () {
        // Act & Assert
        expect(usecase('LDL'), 'LDL Cholesterol');
        expect(usecase('ldl'), 'LDL Cholesterol');
        expect(usecase('LDL CHOLESTEROL'), 'LDL Cholesterol');
      });

      test('should normalize HDL variations to "HDL Cholesterol"', () {
        // Act & Assert
        expect(usecase('HDL'), 'HDL Cholesterol');
        expect(usecase('hdl'), 'HDL Cholesterol');
        expect(usecase('HDL CHOLESTEROL'), 'HDL Cholesterol');
      });

      test('should normalize triglycerides variations', () {
        // Act & Assert
        expect(usecase('TRIG'), 'Triglycerides');
        expect(usecase('trig'), 'Triglycerides');
        expect(usecase('TRIGLYCERIDES'), 'Triglycerides');
      });

      test('should normalize VLDL variations to "VLDL Cholesterol"', () {
        // Act & Assert
        expect(usecase('VLDL'), 'VLDL Cholesterol');
        expect(usecase('vldl'), 'VLDL Cholesterol');
        expect(usecase('VLDL-C'), 'VLDL Cholesterol');
      });
    });

    group('Liver Function', () {
      test('should normalize SGOT/AST variations to "AST"', () {
        // Act & Assert
        expect(usecase('AST'), 'AST');
        expect(usecase('ast'), 'AST');
        expect(usecase('ASPARTATE AMINOTRANSFERASE'), 'AST');
        expect(usecase('aspartate aminotransferase'), 'AST');
      });

      test('should normalize SGPT/ALT variations to "ALT"', () {
        // Act & Assert
        expect(usecase('ALT'), 'ALT');
        expect(usecase('alt'), 'ALT');
        expect(usecase('ALANINE AMINOTRANSFERASE'), 'ALT');
        expect(usecase('alanine aminotransferase'), 'ALT');
      });

      test('should normalize alkaline phosphatase variations', () {
        // Act & Assert
        expect(usecase('ALKALINE PHOSPHATASE'), 'Alkaline Phosphatase');
        expect(usecase('alkaline phosphatase'), 'Alkaline Phosphatase');
      });

      test('should normalize bilirubin variations', () {
        // Act & Assert
        expect(usecase('BILI'), 'Bilirubin');
        expect(usecase('bili'), 'Bilirubin');
        expect(usecase('BILIRUBIN'), 'Bilirubin');
        expect(usecase('TOTAL BILIRUBIN'), 'Total Bilirubin');
      });

      test('should normalize albumin variations', () {
        // Act & Assert
        expect(usecase('ALB'), 'Albumin');
        expect(usecase('alb'), 'Albumin');
        expect(usecase('ALBUMIN'), 'Albumin');
      });

      test('should normalize total protein variations', () {
        // Act & Assert
        expect(usecase('TP'), 'Total Protein');
        expect(usecase('tp'), 'Total Protein');
        expect(usecase('TOTAL PROTEIN'), 'Total Protein');
      });
    });

    group('Kidney Function', () {
      test('should normalize BUN variations to "Blood Urea Nitrogen"', () {
        // Act & Assert
        expect(usecase('BLOOD UREA NITROGEN'), 'Blood Urea Nitrogen');
        expect(usecase('blood urea nitrogen'), 'Blood Urea Nitrogen');
      });

      test('should normalize creatinine variations', () {
        // Act & Assert
        expect(usecase('CREATININE'), 'Creatinine');
        expect(usecase('creatinine'), 'Creatinine');
      });

      test('should normalize uric acid variations', () {
        // Act & Assert
        expect(usecase('UA'), 'Uric Acid');
        expect(usecase('ua'), 'Uric Acid');
        expect(usecase('URIC ACID'), 'Uric Acid');
      });

      test('should normalize eGFR variations', () {
        // Act & Assert
        expect(usecase('EGFR'), 'eGFR');
        expect(usecase('egfr'), 'eGFR');
        expect(usecase('eGFR'), 'eGFR');
      });
    });

    group('Diabetes Markers', () {
      test('should normalize glucose variations', () {
        // Act & Assert
        expect(usecase('GLUC'), 'Glucose');
        expect(usecase('gluc'), 'Glucose');
        expect(usecase('GLU'), 'Glucose');
        expect(usecase('GLUCOSE'), 'Glucose');
        expect(usecase('FBS'), 'Fasting Glucose');
        expect(usecase('fbs'), 'Fasting Glucose');
      });

      test('should normalize HbA1c variations', () {
        // Act & Assert
        expect(usecase('HBA1C'), 'HbA1c');
        expect(usecase('hba1c'), 'HbA1c');
        expect(usecase('A1C'), 'HbA1c');
        expect(usecase('a1c'), 'HbA1c');
        expect(usecase('HEMOGLOBIN A1C'), 'HbA1c');
      });
    });

    group('Thyroid Panel', () {
      test('should normalize TSH variations', () {
        // Act & Assert
        expect(usecase('TSH'), 'TSH');
        expect(usecase('tsh'), 'TSH');
        expect(usecase('THYROID STIMULATING HORMONE'), 'TSH');
      });

      test('should normalize T3 variations', () {
        // Act & Assert
        expect(usecase('T3'), 'T3');
        expect(usecase('t3'), 'T3');
        expect(usecase('TRIIODOTHYRONINE'), 'T3');
      });

      test('should normalize T4 variations', () {
        // Act & Assert
        expect(usecase('T4'), 'T4');
        expect(usecase('t4'), 'T4');
        expect(usecase('THYROXINE'), 'T4');
      });

      test('should normalize Free T3 variations', () {
        // Act & Assert
        expect(usecase('FT3'), 'Free T3');
        expect(usecase('ft3'), 'Free T3');
        expect(usecase('FREE T3'), 'Free T3');
      });

      test('should normalize Free T4 variations', () {
        // Act & Assert
        expect(usecase('FT4'), 'Free T4');
        expect(usecase('ft4'), 'Free T4');
        expect(usecase('FREE T4'), 'Free T4');
      });
    });

    group('Vitamins', () {
      test('should normalize Vitamin D variations', () {
        // Act & Assert
        expect(usecase('VIT D'), 'Vitamin D');
        expect(usecase('vit d'), 'Vitamin D');
        expect(usecase('VITAMIN D'), 'Vitamin D');
        expect(usecase('25-OH VIT D'), 'Vitamin D');
        expect(usecase('25-oh vit d'), 'Vitamin D');
      });

      test('should normalize Vitamin B12 variations', () {
        // Act & Assert
        expect(usecase('VIT B12'), 'Vitamin B12');
        expect(usecase('vit b12'), 'Vitamin B12');
        expect(usecase('VITAMIN B12'), 'Vitamin B12');
        expect(usecase('B12'), 'Vitamin B12');
      });

      test('should normalize Folate variations', () {
        // Act & Assert
        expect(usecase('FOLATE'), 'Folate');
        expect(usecase('folate'), 'Folate');
        expect(usecase('FOLIC ACID'), 'Folate');
      });
    });

    group('Iron Studies', () {
      test('should normalize Iron variations', () {
        // Act & Assert
        expect(usecase('FE'), 'Iron');
        expect(usecase('fe'), 'Iron');
        expect(usecase('IRON'), 'Iron');
      });

      test('should normalize Serum Iron variations', () {
        // Act & Assert
        expect(usecase('SERUM IRON'), 'Serum Iron');
        expect(usecase('serum iron'), 'Serum Iron');
      });

      test('should normalize Ferritin variations', () {
        // Act & Assert
        expect(usecase('FERRITIN'), 'Ferritin');
        expect(usecase('ferritin'), 'Ferritin');
        expect(usecase('SERUM FERRITIN'), 'Ferritin');
      });

      test('should normalize TIBC variations', () {
        // Act & Assert
        expect(usecase('TIBC'), 'TIBC');
        expect(usecase('tibc'), 'TIBC');
        expect(usecase('TOTAL IRON BINDING CAPACITY'), 'TIBC');
      });
    });

    group('Inflammation Markers', () {
      test('should normalize CRP variations', () {
        // Act & Assert
        expect(usecase('CRP'), 'C-Reactive Protein');
        expect(usecase('crp'), 'C-Reactive Protein');
        expect(usecase('C-REACTIVE PROTEIN'), 'C-Reactive Protein');
      });

      test('should normalize ESR variations', () {
        // Act & Assert
        expect(usecase('ESR'), 'ESR');
        expect(usecase('esr'), 'ESR');
        expect(usecase('ERYTHROCYTE SEDIMENTATION RATE'), 'ESR');
      });
    });

    group('Additional Electrolytes', () {
      test('should normalize Chloride variations', () {
        // Act & Assert
        expect(usecase('CHLORIDE'), 'Chloride');
        expect(usecase('chloride'), 'Chloride');
      });

      test('should normalize Calcium variations', () {
        // Act & Assert
        expect(usecase('CA'), 'Calcium');
        expect(usecase('ca'), 'Calcium');
        expect(usecase('CA++'), 'Calcium');
        expect(usecase('CALCIUM'), 'Calcium');
      });

      test('should normalize Magnesium variations', () {
        // Act & Assert
        expect(usecase('MG'), 'Magnesium');
        expect(usecase('mg'), 'Magnesium');
        expect(usecase('MG++'), 'Magnesium');
      });
    });

    group('Complete Blood Count', () {
      test('should normalize Platelets variations', () {
        // Act & Assert
        expect(usecase('PLT'), 'Platelets');
        expect(usecase('plt'), 'Platelets');
        expect(usecase('PLATELET'), 'Platelets');
        expect(usecase('PLATELET COUNT'), 'Platelets');
      });

      test('should normalize Hematocrit variations', () {
        // Act & Assert
        expect(usecase('HCT'), 'Hematocrit');
        expect(usecase('hct'), 'Hematocrit');
        expect(usecase('HEMATOCRIT'), 'Hematocrit');
      });

      test('should normalize MCV variations', () {
        // Act & Assert
        expect(usecase('MCV'), 'Mean Corpuscular Volume');
        expect(usecase('mcv'), 'Mean Corpuscular Volume');
        expect(usecase('MEAN CORPUSCULAR VOLUME'), 'Mean Corpuscular Volume');
      });

      test('should normalize MCH variations', () {
        // Act & Assert
        expect(usecase('MCH'), 'Mean Corpuscular Hemoglobin');
        expect(usecase('mch'), 'Mean Corpuscular Hemoglobin');
      });

      test('should normalize MCHC variations', () {
        // Act & Assert
        expect(usecase('MCHC'), 'Mean Corpuscular Hemoglobin Concentration');
        expect(usecase('mchc'), 'Mean Corpuscular Hemoglobin Concentration');
      });
    });
  });
}
