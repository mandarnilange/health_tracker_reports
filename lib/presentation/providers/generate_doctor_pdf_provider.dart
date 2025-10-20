import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/domain/usecases/generate_doctor_pdf.dart';

final generateDoctorPdfProvider = Provider<GenerateDoctorPdf>((ref) {
  return getIt<GenerateDoctorPdf>();
});
