import 'package:flutter/material.dart';

class SlowLoadingBar extends StatefulWidget {
  final int duration;

  SlowLoadingBar({
    required this.duration,
    super.key
});

  @override
  _SlowLoadingBarState createState() => _SlowLoadingBarState();
}

class _SlowLoadingBarState extends State<SlowLoadingBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return SizedBox(
          width: 400,
          height: 8,
          child: LinearProgressIndicator(
            value: _controller.value,
            backgroundColor: Colors.white70,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        );
      },
    );
  }
}

