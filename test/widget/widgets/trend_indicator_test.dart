import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';
import 'package:health_tracker_reports/presentation/widgets/trend_indicator.dart';

void main() {
  group('TrendIndicator', () {
    testWidgets('displays up arrow for increasing trend',
        (WidgetTester tester) async {
      // Arrange
      const trendAnalysis = TrendAnalysis(
        direction: TrendDirection.increasing,
        percentageChange: 15.5,
        firstValue: 100.0,
        lastValue: 115.5,
        dataPointsCount: 5,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(trendAnalysis: trendAnalysis),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('displays down arrow for decreasing trend',
        (WidgetTester tester) async {
      // Arrange
      const trendAnalysis = TrendAnalysis(
        direction: TrendDirection.decreasing,
        percentageChange: -15.5,
        firstValue: 100.0,
        lastValue: 84.5,
        dataPointsCount: 5,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(trendAnalysis: trendAnalysis),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('displays forward arrow for stable trend',
        (WidgetTester tester) async {
      // Arrange
      const trendAnalysis = TrendAnalysis(
        direction: TrendDirection.stable,
        percentageChange: 2.5,
        firstValue: 100.0,
        lastValue: 102.5,
        dataPointsCount: 5,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(trendAnalysis: trendAnalysis),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('displays percentage with + sign for positive change',
        (WidgetTester tester) async {
      // Arrange
      const trendAnalysis = TrendAnalysis(
        direction: TrendDirection.increasing,
        percentageChange: 15.5,
        firstValue: 100.0,
        lastValue: 115.5,
        dataPointsCount: 5,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(trendAnalysis: trendAnalysis),
          ),
        ),
      );

      // Assert
      expect(find.text('+15.5%'), findsOneWidget);
    });

    testWidgets('displays percentage with - sign for negative change',
        (WidgetTester tester) async {
      // Arrange
      const trendAnalysis = TrendAnalysis(
        direction: TrendDirection.decreasing,
        percentageChange: -15.5,
        firstValue: 100.0,
        lastValue: 84.5,
        dataPointsCount: 5,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(trendAnalysis: trendAnalysis),
          ),
        ),
      );

      // Assert
      expect(find.text('-15.5%'), findsOneWidget);
    });

    testWidgets('displays percentage with + sign for stable positive change',
        (WidgetTester tester) async {
      // Arrange
      const trendAnalysis = TrendAnalysis(
        direction: TrendDirection.stable,
        percentageChange: 2.5,
        firstValue: 100.0,
        lastValue: 102.5,
        dataPointsCount: 3,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(trendAnalysis: trendAnalysis),
          ),
        ),
      );

      // Assert
      expect(find.text('+2.5%'), findsOneWidget);
    });

    testWidgets('displays 0.0% for zero change', (WidgetTester tester) async {
      // Arrange
      const trendAnalysis = TrendAnalysis(
        direction: TrendDirection.stable,
        percentageChange: 0.0,
        firstValue: 100.0,
        lastValue: 100.0,
        dataPointsCount: 3,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(trendAnalysis: trendAnalysis),
          ),
        ),
      );

      // Assert
      expect(find.text('0.0%'), findsOneWidget);
    });

    testWidgets('formats percentage with one decimal place',
        (WidgetTester tester) async {
      // Arrange
      const trendAnalysis = TrendAnalysis(
        direction: TrendDirection.increasing,
        percentageChange: 15.67,
        firstValue: 100.0,
        lastValue: 115.67,
        dataPointsCount: 3,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(trendAnalysis: trendAnalysis),
          ),
        ),
      );

      // Assert
      expect(find.text('+15.7%'), findsOneWidget);
    });

    testWidgets('uses green color for increasing trend',
        (WidgetTester tester) async {
      // Arrange
      const trendAnalysis = TrendAnalysis(
        direction: TrendDirection.increasing,
        percentageChange: 15.5,
        firstValue: 100.0,
        lastValue: 115.5,
        dataPointsCount: 5,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(trendAnalysis: trendAnalysis),
          ),
        ),
      );

      // Assert
      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_upward));
      expect(icon.color, Colors.green);

      final text = tester.widget<Text>(find.text('+15.5%'));
      expect(text.style?.color, Colors.green);
    });

    testWidgets('uses red color for decreasing trend',
        (WidgetTester tester) async {
      // Arrange
      const trendAnalysis = TrendAnalysis(
        direction: TrendDirection.decreasing,
        percentageChange: -15.5,
        firstValue: 100.0,
        lastValue: 84.5,
        dataPointsCount: 5,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(trendAnalysis: trendAnalysis),
          ),
        ),
      );

      // Assert
      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_downward));
      expect(icon.color, Colors.red);

      final text = tester.widget<Text>(find.text('-15.5%'));
      expect(text.style?.color, Colors.red);
    });

    testWidgets('uses orange color for stable trend',
        (WidgetTester tester) async {
      // Arrange
      const trendAnalysis = TrendAnalysis(
        direction: TrendDirection.stable,
        percentageChange: 2.5,
        firstValue: 100.0,
        lastValue: 102.5,
        dataPointsCount: 5,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(trendAnalysis: trendAnalysis),
          ),
        ),
      );

      // Assert
      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_forward));
      expect(icon.color, Colors.orange);

      final text = tester.widget<Text>(find.text('+2.5%'));
      expect(text.style?.color, Colors.orange);
    });

    testWidgets('has compact size suitable for inline display',
        (WidgetTester tester) async {
      // Arrange
      const trendAnalysis = TrendAnalysis(
        direction: TrendDirection.increasing,
        percentageChange: 15.5,
        firstValue: 100.0,
        lastValue: 115.5,
        dataPointsCount: 5,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(trendAnalysis: trendAnalysis),
          ),
        ),
      );

      // Assert
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisSize, MainAxisSize.min);

      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_upward));
      expect(icon.size, 16.0);

      final text = tester.widget<Text>(find.text('+15.5%'));
      expect(text.style?.fontSize, 12.0);
    });

    testWidgets('handles very large percentage changes',
        (WidgetTester tester) async {
      // Arrange
      const trendAnalysis = TrendAnalysis(
        direction: TrendDirection.increasing,
        percentageChange: 150.5,
        firstValue: 100.0,
        lastValue: 250.5,
        dataPointsCount: 3,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(trendAnalysis: trendAnalysis),
          ),
        ),
      );

      // Assert
      expect(find.text('+150.5%'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('handles very small percentage changes',
        (WidgetTester tester) async {
      // Arrange
      const trendAnalysis = TrendAnalysis(
        direction: TrendDirection.stable,
        percentageChange: 0.1,
        firstValue: 100.0,
        lastValue: 100.1,
        dataPointsCount: 2,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(trendAnalysis: trendAnalysis),
          ),
        ),
      );

      // Assert
      expect(find.text('+0.1%'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('uses FontWeight.bold for text', (WidgetTester tester) async {
      // Arrange
      const trendAnalysis = TrendAnalysis(
        direction: TrendDirection.increasing,
        percentageChange: 15.5,
        firstValue: 100.0,
        lastValue: 115.5,
        dataPointsCount: 5,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(trendAnalysis: trendAnalysis),
          ),
        ),
      );

      // Assert
      final text = tester.widget<Text>(find.text('+15.5%'));
      expect(text.style?.fontWeight, FontWeight.bold);
    });
  });
}
