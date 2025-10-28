import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/presentation/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    test('exposes distinct biomarker status palettes', () {
      expect(AppColors.normalGreen, const Color(0xFF4CAF50));
      expect(AppColors.warningYellowDark, const Color(0xFFF57C00));
      expect(AppColors.dangerRedLight, const Color(0xFFE57373));
    });

    test('provides matching light and dark theme colors', () {
      expect(AppColors.lightPrimary, const Color(0xFF2196F3));
      expect(AppColors.darkPrimaryVariant, const Color(0xFF42A5F5));
      expect(AppColors.lightOnSurface, const Color(0xFF212121));
      expect(AppColors.darkOnSurfaceVariant, const Color(0xFFBDBDBD));
    });

    test('defines chart palettes with expected entries', () {
      expect(AppColors.chartColors.length, 8);
      expect(
        AppColors.chartGradientColors,
        const [Color(0x662196F3), Color(0x004CAF50)],
      );
    });
  });
}
