import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class GyroCardWidget extends StatefulWidget {
  final Widget child;
  final bool enableGyro;
  final double sensitivity;

  const GyroCardWidget({
    Key? key,
    required this.child,
    this.enableGyro = true,
    this.sensitivity = 1.0,
  }) : super(key: key);

  @override
  _GyroCardWidgetState createState() => _GyroCardWidgetState();
}

class _GyroCardWidgetState extends State<GyroCardWidget>
    with TickerProviderStateMixin {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  Timer? _gyroTimer;

  @override
  void initState() {
    super.initState();
    if (widget.enableGyro) {
      _startGyroSimulation();
    }
  }

  void _startGyroSimulation() {
    _gyroTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (!mounted || !widget.enableGyro) {
        timer.cancel();
        return;
      }

      final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
      final newTiltX = math.sin(time * 0.5) * 0.2 * widget.sensitivity;
      final newTiltY = math.cos(time * 0.3) * 0.15 * widget.sensitivity;

      setState(() {
        _tiltX = newTiltX;
        _tiltY = newTiltY;
      });
    });
  }

  @override
  void didUpdateWidget(GyroCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableGyro != oldWidget.enableGyro) {
      if (widget.enableGyro) {
        _startGyroSimulation();
      } else {
        _gyroTimer?.cancel();
        setState(() {
          _tiltX = 0.0;
          _tiltY = 0.0;
        });
      }
    }
  }

  @override
  void dispose() {
    _gyroTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(_tiltX)
        ..rotateY(_tiltY),
      child: widget.child,
    );
  }
}
