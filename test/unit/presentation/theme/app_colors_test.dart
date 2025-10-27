import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/presentation/theme/app_colors.dart';

void main() {
  test('chart colors expose palette', () {
    expect(AppColors.chartColors, hasLength(8));
    expect(AppColors.chartGradientColors, hasLength(2));
    expect(AppColors.normalGreen.value, 0xFF4CAF50);
  });
}
