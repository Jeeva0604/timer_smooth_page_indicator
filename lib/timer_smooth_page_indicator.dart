import 'dart:async';

import 'package:flutter/material.dart';

class TimerSmoothPageIndicator extends StatefulWidget {
  final int totalLength;
  final int durationInSeconds;
  final double indicatorWidth;
  final double activeIndicatorWidth;
  final double indicatorHeight;
  final Color indicatorColor;
  final Color progressColor;
  final double spacing;
  final Curve curve;

  const TimerSmoothPageIndicator({
    super.key,
    required this.totalLength,
    this.durationInSeconds = 3,
    this.indicatorWidth = 25,
    this.activeIndicatorWidth = 45,
    this.indicatorHeight = 8,
    this.indicatorColor = const Color(0xFFE0E0E0),
    this.progressColor = Colors.black,
    this.spacing = 4,
    this.curve = Curves.linear,
  });

  @override
  State<TimerSmoothPageIndicator> createState() =>
      _TimerSmoothPageIndicatorState();
}

class _TimerSmoothPageIndicatorState extends State<TimerSmoothPageIndicator>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _progressController;
  late AnimationController _widthController;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: Duration(seconds: widget.durationInSeconds),
      vsync: this,
    )..addListener(() {
      if (!mounted) return;
      setState(() {});
    });

    _widthController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();

    _startAutoPlay();
    _progressController.forward();
  }

  void _startAutoPlay() {
    _autoTimer = Timer.periodic(
      Duration(seconds: widget.durationInSeconds),
      (_) => _nextIndicator(),
    );
  }

  void _nextIndicator() {
    if (!mounted) return;

    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.totalLength;

      _progressController
        ..reset()
        ..forward();

      _widthController
        ..reset()
        ..forward();
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();

    if (_progressController.isAnimating) {
      _progressController.stop();
    }

    if (_widthController.isAnimating) {
      _widthController.stop();
    }

    _progressController.dispose();
    _widthController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(widget.totalLength, (index) {
          final isActive = index == _currentIndex;
          final width =
              isActive
                  ? Tween<double>(
                        begin: widget.indicatorWidth,
                        end: widget.activeIndicatorWidth,
                      )
                      .animate(
                        CurvedAnimation(
                          parent: _widthController,
                          curve: widget.curve,
                        ),
                      )
                      .value
                  : widget.indicatorWidth;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: widget.curve,
            width: width,
            height: widget.indicatorHeight,
            margin: EdgeInsets.symmetric(horizontal: widget.spacing),
            decoration: BoxDecoration(
              color: widget.indicatorColor,
              borderRadius: BorderRadius.circular(widget.indicatorHeight / 2),
            ),
            child:
                isActive
                    ? Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _progressController.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.progressColor,
                            borderRadius: BorderRadius.circular(
                              widget.indicatorHeight / 2,
                            ),
                          ),
                        ),
                      ),
                    )
                    : null,
          );
        }),
      ),
    );
  }
}
