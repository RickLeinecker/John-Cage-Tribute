import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

import 'package:jct/src/animations/circle_painter.dart';
import 'package:jct/src/animations/curve_wave.dart';

class FlashingMusicIcon extends StatefulWidget {
  const FlashingMusicIcon({
    Key key,
    this.size = 25.0,
    this.color = Colors.amber,
    this.onPressed,
  }) : super(key: key);
  final double size;
  final Color color;
  final VoidCallback onPressed;

  _FlashingMusicIconState createState() => _FlashingMusicIconState();
}

class _FlashingMusicIconState extends State<FlashingMusicIcon>
    with TickerProviderStateMixin {
  AnimationController _controller;

  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  Widget _button() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[
                widget.color,
                Color.lerp(widget.color, Colors.black, .05)
              ],
            ),
          ),
          child: ScaleTransition(
              scale: Tween(begin: 0.85, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: const CurveWave(),
                ),
              ),
              child: Icon(
                Icons.music_note,
                size: 20,
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CirclePainter(
        _controller,
        color: widget.color,
      ),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: _button(),
      ),
    );
  }
}
