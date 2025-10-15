
import 'package:injectable/injectable.dart';

@lazySingleton
class NormalizeBiomarkerName {
  final Map<String, String> _normalizationMap = {
    // Electrolytes
    'NA': 'Sodium',
    'NA+': 'Sodium',
    'SODIUM': 'Sodium',
    'K': 'Potassium',
    'K+': 'Potassium',
    'POTASSIUM': 'Potassium',
    'CL': 'Chloride',
    'CL-': 'Chloride',

    // Blood count
    'HB': 'Hemoglobin',
    'HEMOGLOBIN': 'Hemoglobin',
    'WBC': 'White Blood Cells',
    'TLC': 'White Blood Cells',
    'RBC': 'Red Blood Cells',

    // Lipids
    'CHOL': 'Total Cholesterol',
    'TC': 'Total Cholesterol',
    'LDL-C': 'LDL Cholesterol',
    'HDL-C': 'HDL Cholesterol',
    'TG': 'Triglycerides',

    // Liver
    'SGOT': 'AST',
    'SGPT': 'ALT',
    'ALK PHOS': 'Alkaline Phosphatase',
    'ALP': 'Alkaline Phosphatase',

    // Kidney
    'BUN': 'Blood Urea Nitrogen',
    'CREAT': 'Creatinine',
    'CR': 'Creatinine',
  };

  String call(String? name) {
    if (name == null || name.isEmpty) {
      return '';
    }

    final upperCaseName = name.toUpperCase();
    return _normalizationMap[upperCaseName] ?? name;
  }
}
