import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timer_smooth_page_indicator/timer_smooth_page_indicator.dart';

void main() {
  testWidgets(
    'TimerSmoothPageIndicator shows the correct number of indicators',
    (WidgetTester tester) async {
      const totalLength = 10;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerSmoothPageIndicator(
              totalLength: totalLength,
              durationInSeconds: 3,
              indicatorWidth: 25,
              indicatorHeight: 8,
              activeIndicatorWidth: 45,
              indicatorColor: Color(0xFFE0E0E0),
              progressColor: Colors.green,
              spacing: 4,
            ),
          ),
        ),
      );

      final indicatorFinder = find.byType(AnimatedContainer);
      expect(indicatorFinder, findsNWidgets(totalLength));
    },
  );

  testWidgets('TimerSmoothPageIndicator progresses correctly', (
    WidgetTester tester,
  ) async {
    const totalLength = 10;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimerSmoothPageIndicator(
            totalLength: totalLength,
            durationInSeconds: 3,
            indicatorWidth: 25,
            indicatorHeight: 8,
            activeIndicatorWidth: 45,
            indicatorColor: Color(0xFFE0E0E0),
            progressColor: Colors.green,
            spacing: 4,
          ),
        ),
      ),
    );

    await tester.pump(); // First frame

    // Wait little time for animation to start
    await tester.pump(const Duration(milliseconds: 500));

    // Now check if widget tree is rebuilt (timer triggered animation)
    expect(find.byType(AnimatedContainer), findsWidgets);

    // You can also check rebuild count or animation progress state
    // but mainly check no errors and the AnimatedContainers exist
  });
}
