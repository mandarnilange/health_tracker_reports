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
    'CHLORIDE': 'Chloride',
    'CA': 'Calcium',
    'CA++': 'Calcium',
    'CALCIUM': 'Calcium',
    'MG': 'Magnesium',
    'MG++': 'Magnesium',

    // Complete Blood Count
    'HB': 'Hemoglobin',
    'HEMOGLOBIN': 'Hemoglobin',
    'WBC': 'White Blood Cells',
    'TLC': 'White Blood Cells',
    'WHITE BLOOD CELLS': 'White Blood Cells',
    'RBC': 'Red Blood Cells',
    'RED BLOOD CELLS': 'Red Blood Cells',
    'PLT': 'Platelets',
    'PLATELET': 'Platelets',
    'PLATELET COUNT': 'Platelets',
    'HCT': 'Hematocrit',
    'HEMATOCRIT': 'Hematocrit',
    'MCV': 'Mean Corpuscular Volume',
    'MEAN CORPUSCULAR VOLUME': 'Mean Corpuscular Volume',
    'MCH': 'Mean Corpuscular Hemoglobin',
    'MCHC': 'Mean Corpuscular Hemoglobin Concentration',

    // Lipid Panel
    'CHOL': 'Total Cholesterol',
    'TC': 'Total Cholesterol',
    'TOTAL CHOLESTEROL': 'Total Cholesterol',
    'LDL': 'LDL Cholesterol',
    'LDL-C': 'LDL Cholesterol',
    'LDL CHOLESTEROL': 'LDL Cholesterol',
    'HDL': 'HDL Cholesterol',
    'HDL-C': 'HDL Cholesterol',
    'HDL CHOLESTEROL': 'HDL Cholesterol',
    'TG': 'Triglycerides',
    'TRIG': 'Triglycerides',
    'TRIGLYCERIDES': 'Triglycerides',
    'VLDL': 'VLDL Cholesterol',
    'VLDL-C': 'VLDL Cholesterol',

    // Liver Function
    'SGOT': 'AST',
    'AST': 'AST',
    'ASPARTATE AMINOTRANSFERASE': 'AST',
    'SGPT': 'ALT',
    'ALT': 'ALT',
    'ALANINE AMINOTRANSFERASE': 'ALT',
    'ALK PHOS': 'Alkaline Phosphatase',
    'ALP': 'Alkaline Phosphatase',
    'ALKALINE PHOSPHATASE': 'Alkaline Phosphatase',
    'BILI': 'Bilirubin',
    'BILIRUBIN': 'Bilirubin',
    'TOTAL BILIRUBIN': 'Total Bilirubin',
    'ALB': 'Albumin',
    'ALBUMIN': 'Albumin',
    'TP': 'Total Protein',
    'TOTAL PROTEIN': 'Total Protein',

    // Kidney Function
    'BUN': 'Blood Urea Nitrogen',
    'BLOOD UREA NITROGEN': 'Blood Urea Nitrogen',
    'CREAT': 'Creatinine',
    'CR': 'Creatinine',
    'CREATININE': 'Creatinine',
    'UA': 'Uric Acid',
    'URIC ACID': 'Uric Acid',
    'EGFR': 'eGFR',

    // Diabetes Markers
    'GLUC': 'Glucose',
    'GLU': 'Glucose',
    'GLUCOSE': 'Glucose',
    'FBS': 'Fasting Glucose',
    'HBA1C': 'HbA1c',
    'A1C': 'HbA1c',
    'HEMOGLOBIN A1C': 'HbA1c',

    // Thyroid Panel
    'TSH': 'TSH',
    'THYROID STIMULATING HORMONE': 'TSH',
    'T3': 'T3',
    'TRIIODOTHYRONINE': 'T3',
    'T4': 'T4',
    'THYROXINE': 'T4',
    'FT3': 'Free T3',
    'FREE T3': 'Free T3',
    'FT4': 'Free T4',
    'FREE T4': 'Free T4',

    // Vitamins
    'VIT D': 'Vitamin D',
    'VITAMIN D': 'Vitamin D',
    '25-OH VIT D': 'Vitamin D',
    'VIT B12': 'Vitamin B12',
    'VITAMIN B12': 'Vitamin B12',
    'B12': 'Vitamin B12',
    'FOLATE': 'Folate',
    'FOLIC ACID': 'Folate',

    // Iron Studies
    'FE': 'Iron',
    'IRON': 'Iron',
    'SERUM IRON': 'Serum Iron',
    'FERRITIN': 'Ferritin',
    'SERUM FERRITIN': 'Ferritin',
    'TIBC': 'TIBC',
    'TOTAL IRON BINDING CAPACITY': 'TIBC',

    // Inflammation Markers
    'CRP': 'C-Reactive Protein',
    'C-REACTIVE PROTEIN': 'C-Reactive Protein',
    'ESR': 'ESR',
    'ERYTHROCYTE SEDIMENTATION RATE': 'ESR',
  };

  String call(String? name) {
    if (name == null || name.isEmpty) {
      return '';
    }

    final upperCaseName = name.toUpperCase();
    return _normalizationMap[upperCaseName] ?? name;
  }
}
