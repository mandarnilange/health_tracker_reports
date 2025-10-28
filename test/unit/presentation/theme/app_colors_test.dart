import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/presentation/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    test('provides light and dark theme primary colors', () {
      expect(AppColors.lightPrimary, const Color(0xFF2196F3));
      expect(AppColors.darkPrimary, const Color(0xFF64B5F6));
    });

    test('exposes chart color palette with expected length', () {
      expect(AppColors.chartColors.length, 8);
      expect(AppColors.chartColors, contains(const Color(0xFF4CAF50)));
    });

    test('exposes chart gradient palette with transparency encoded', () {
      expect(AppColors.chartGradientColors.length, 2);
      expect(AppColors.chartGradientColors.first.alpha, greaterThan(0));
    });
  });
}
