import 'dart:async';
import 'package:flutter/material.dart';

/// A widget that displays a smooth, timer-based page indicator.
///
/// This indicator shows a sequence of circles that grow and shrink to represent
/// a progress bar. It is useful for displaying timed steps or progress in
/// a carousel-like UI. The widget can be customized with parameters like
/// duration, size, and colors.
class TimerSmoothPageIndicator extends StatefulWidget {
  /// The total number of indicators to be displayed.
  final int totalLength;

  /// The duration for each indicator to complete its progress animation, in seconds.
  final int durationInSeconds;

  /// The width of each inactive indicator.
  final double indicatorWidth;

  /// The width of the active indicator.
  final double activeIndicatorWidth;

  /// The height of each indicator.
  final double indicatorHeight;

  /// The color of the inactive indicators.
  final Color indicatorColor;

  /// The color of the active indicator's progress.
  final Color progressColor;

  /// The spacing between each indicator.
  final double spacing;

  /// The curve applied to the animation for indicator width changes.
  final Curve curve;

  /// Whether the indicator should auto-play and move to the next indicator.
  final bool autoPlay;

  /// Creates a [TimerSmoothPageIndicator] widget.
  ///
  /// The [totalLength] is required and represents the number of indicators.
  /// The [durationInSeconds] is the time each indicator takes to complete.
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

/// The state for the [TimerSmoothPageIndicator] widget.
///
/// This class manages the animations for the indicator progress and width changes,
/// as well as handling auto-play and app lifecycle events (e.g., pause, resume).
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

  /// Initializes the animation controllers for the progress and width animations.
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

  /// Starts the animations for the indicator's progress and width.
  void _startAnimations() {
    _progressController.forward(from: 0.0);
    _widthController.forward();

    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  /// Starts the auto-play functionality that moves to the next indicator after the specified duration.
  void _startAutoPlay() {
    _autoTimer?.cancel();
    _autoTimer = Timer(Duration(seconds: widget.durationInSeconds), () {
      if (mounted) {
        _nextIndicator();
        _startAutoPlay();
      }
    });
  }

  /// Moves to the next indicator, wrapping around if necessary.
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

  /// Handles the app being paused by stopping the animation and storing the elapsed time.
  void _handleAppPaused() {
    _elapsedBeforePause =
        _progressController.duration! * _progressController.value;
    _progressController.stop();
    _autoTimer?.cancel();
    _wasPaused = true;
  }

  /// Resumes the animation from where it was paused when the app is resumed.
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

  /// Handles the app being detached (e.g., app backgrounded or closed).
  void _handleAppDetached() {
    _wasDetached = true;
    _resetToInitialState();
  }

  /// Resets the indicator state to the initial values, stopping any active timers or animations.
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
