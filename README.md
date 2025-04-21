
```md
# timer_smooth_page_indicator

A Flutter package for smooth, timer-based page indicators with customizable styling and transitions.

![Demo](https://raw.githubusercontent.com/Jeeva0604/timer_smooth_page_indicator/refs/heads/main/assets/example.gif)

## Features

- Auto-progressing page indicator
- Fully customizable width, height, spacing, and colors
- Smooth animation transitions
- Perfect for intro or onboarding screens

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  timer_smooth_page_indicator: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

```dart
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
```

## Parameters

| Parameter             | Type     | Description                                 |
|----------------------|----------|---------------------------------------------|
| `totalLength`        | `int`    | Number of indicators                        |
| `durationInSeconds`  | `int`    | Time interval for each animation step       |
| `indicatorWidth`     | `double` | Width of the inactive indicators            |
| `activeIndicatorWidth` | `double` | Width of the active indicator             |
| `indicatorHeight`    | `double` | Height of the indicators                    |
| `indicatorColor`     | `Color`  | Background color of indicators              |
| `progressColor`      | `Color`  | Color for the progressing animation         |
| `spacing`            | `double` | Space between indicators                    |
| `curve`              | `Curve`  | Animation curve                             |

## Author

Made with ❤️ by Jeeva

- [Instagram](https://www.instagram.com/jeeva_r45/)
- [LinkedIn](https://www.linkedin.com/in/jeeva-g-r0628)
- [GitHub](https://github.com/Jeeva0604)

---

⭐ Star this repo if you find it helpful!
```

Let me know if you want a version in Tamil or if you’d like badges added for pub, GitHub stars, etc.