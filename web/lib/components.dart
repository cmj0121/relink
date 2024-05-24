import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  final int size;
  final duration;
  final IconData icon;

  Loading({Key? key, required this.icon, this.size = 5, this.duration = const Duration(seconds: 1)}) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: buildAnimation(),
      ),
    );
  }

  Widget buildAnimation() {
    List<Color> colors = [
      Colors.grey.shade100,
      Colors.grey.shade200,
      Colors.grey.shade300,
      Colors.grey.shade400,
      Colors.grey.shade500,
      Colors.grey.shade600,
      Colors.grey.shade700,
      Colors.grey.shade800,
      Colors.grey.shade900,
    ];
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        int index = (_controller.value * 10).toInt();

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(widget.size, (i) {
            return Icon(
              widget.icon,
              color: colors[(index - i) % colors.length],
            );
          }),
        );
      },
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
