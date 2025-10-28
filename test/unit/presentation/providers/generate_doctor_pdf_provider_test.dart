import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/domain/usecases/generate_doctor_pdf.dart';
import 'package:health_tracker_reports/presentation/providers/generate_doctor_pdf_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockGenerateDoctorPdf extends Mock implements GenerateDoctorPdf {}

void main() {
  setUp(() async {
    await getIt.reset();
  });

  test('generateDoctorPdfProvider exposes registered usecase', () {
    final mockUsecase = _MockGenerateDoctorPdf();
    getIt.registerSingleton<GenerateDoctorPdf>(mockUsecase);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = container.read(generateDoctorPdfProvider);

    expect(result, same(mockUsecase));
  });
}
