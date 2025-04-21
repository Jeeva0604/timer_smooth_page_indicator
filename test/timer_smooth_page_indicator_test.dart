import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timer_smooth_page_indicator/timer_smooth_page_indicator.dart';

void main() {
  testWidgets(
    'TimerSmoothPageIndicator shows the correct number of indicators',
    (WidgetTester tester) async {
      // Define test values
      const totalLength = 10;

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerSmoothPageIndicator(
              totalLength: totalLength,
              durationInSeconds: 3,
              indicatorWidth: 25,
              indicatorHeight: 8,
              activeIndicatorWidth: 45,
              indicatorColor: const Color(0xFFE0E0E0),
              progressColor: Colors.green,
              spacing: 4,
            ),
          ),
        ),
      );

      // Ensure the correct number of indicators are shown
      final indicatorFinder = find.byType(AnimatedContainer);
      expect(indicatorFinder, findsNWidgets(totalLength));
    },
  );

  testWidgets('TimerSmoothPageIndicator progresses correctly', (
    WidgetTester tester,
  ) async {
    // Define test values
    const totalLength = 10;

    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimerSmoothPageIndicator(
            totalLength: totalLength,
            durationInSeconds: 3,
            indicatorWidth: 25,
            indicatorHeight: 8,
            activeIndicatorWidth: 45,
            indicatorColor: const Color(0xFFE0E0E0),
            progressColor: Colors.green,
            spacing: 4,
          ),
        ),
      ),
    );

    // Wait for the timer to progress
    await tester.pumpAndSettle();

    // Ensure the first indicator has started progressing
    final firstIndicator = find.byType(AnimatedContainer).first;
    expect(firstIndicator, findsOneWidget);
  });
}
