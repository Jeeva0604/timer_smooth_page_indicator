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
  final bool autoPlay;

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
    this.autoPlay = true,
  });

  @override
  State<TimerSmoothPageIndicator> createState() =>
      _TimerSmoothPageIndicatorState();
}

class _TimerSmoothPageIndicatorState extends State<TimerSmoothPageIndicator>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  late AnimationController _progressController;
  late AnimationController _widthController;
  Timer? _autoTimer;

  Duration _elapsedBeforePause = Duration.zero;
  bool _wasPaused = false;
  bool _wasDetached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeControllers();
    _startAnimations();
  }

  void _initializeControllers() {
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
    );
  }

  void _startAnimations() {
    _progressController.forward(from: 0.0);
    _widthController.forward();

    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoTimer?.cancel();
    _autoTimer = Timer(Duration(seconds: widget.durationInSeconds), () {
      if (mounted) {
        _nextIndicator();
        _startAutoPlay();
      }
    });
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        break;
    }
  }

  void _handleAppPaused() {
    _elapsedBeforePause =
        _progressController.duration! * _progressController.value;
    _progressController.stop();
    _autoTimer?.cancel();
    _wasPaused = true;
  }

  void _handleAppResumed() {
    if (_wasPaused || _wasDetached) {
      final remainingDuration =
          Duration(seconds: widget.durationInSeconds) - _elapsedBeforePause;

      _progressController.forward(
        from:
            _elapsedBeforePause.inMilliseconds /
            _progressController.duration!.inMilliseconds,
      );

      if (widget.autoPlay) {
        _autoTimer?.cancel();
        _autoTimer = Timer(remainingDuration, () {
          if (mounted) {
            _nextIndicator();
            _startAutoPlay();
          }
        });
      }

      _wasPaused = false;
      _wasDetached = false;
    }
  }

  void _handleAppDetached() {
    _wasDetached = true;
    _resetToInitialState();
  }

  void _resetToInitialState() {
    _currentIndex = 0;
    _elapsedBeforePause = Duration.zero;
    _progressController.reset();
    _widthController.reset();
    _autoTimer?.cancel();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoTimer?.cancel();
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
          double width = widget.indicatorWidth;

          if (isActive) {
            width =
                Tween<double>(
                      begin: widget.indicatorWidth,
                      end: widget.activeIndicatorWidth,
                    )
                    .animate(
                      CurvedAnimation(
                        parent: _widthController,
                        curve: widget.curve,
                      ),
                    )
                    .value;
          }

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
