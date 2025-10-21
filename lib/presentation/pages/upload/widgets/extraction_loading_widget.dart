import 'dart:async';
import 'package:flutter/material.dart';

/// A widget to be displayed while biomarker extraction is in progress.
///
/// It shows a loading indicator and cycles through a series of informative
/// messages to keep the user engaged.
class ExtractionLoadingWidget extends StatefulWidget {
  const ExtractionLoadingWidget({super.key});

  @override
  State<ExtractionLoadingWidget> createState() => _ExtractionLoadingWidgetState();
}

class _ExtractionLoadingWidgetState extends State<ExtractionLoadingWidget> {
  int _messageIndex = 0;
  Timer? _timer;

  // The list of messages to be displayed.
  static const List<String> _messages = [
    'Analyzing your report with our powerful AI to identify key biomarkers...',
    'Your privacy is our priority. All your health data is stored securely on your device, never in the cloud.',
    'Did you know? You can also track daily vitals like heart rate and blood pressure to build a fuller health picture.',
    'Get ready to visualize your health trends. See how your biomarkers change over time with our interactive charts.',
    'After extraction, you can generate a clean summary PDF to share with your healthcare provider.',
    'Tip: For the most accurate results, please use clear, high-quality PDF reports.',
  ];

  @override
  void initState() {
    super.initState();
    // Start a timer to cycle through the messages every 4 seconds.
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    // Clean up the timer when the widget is removed.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Loader at the top of the screen.
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
              const SizedBox(height: 50),

              // Animated text that expands to fill the remaining space.
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 750),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: Text(
                      _messages[_messageIndex],
                      key: ValueKey<String>(_messages[_messageIndex]),
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
