import 'package:flutter/material.dart';
import 'package:timer_smooth_page_indicator/timer_smooth_page_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: TimerSmoothPageIndicator(
            totalLength: 10,
            durationInSeconds: 3,
            indicatorWidth: 25,
            activeIndicatorWidth: 45,
            indicatorHeight: 8,
            indicatorColor: const Color(0xFFE0E0E0),
            progressColor: Colors.black,
            spacing: 4,
            curve: Curves.linear,
          ),
        ),
      ),
    );
  }
}
