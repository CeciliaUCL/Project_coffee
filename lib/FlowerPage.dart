import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class FlowerPage extends StatefulWidget {
  @override
  _FlowerPageState createState() => _FlowerPageState();
}

class _FlowerPageState extends State<FlowerPage> {
  int _currentPointIndex = 0;
  int _lastDroppedIndex = -1;
  bool _startEnabled = true;
  bool _moveEnabled = false;
  bool _retryEnabled = false;
  bool _dropEnabled = false;
  List<Color> _pointColors = [Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey];
  Timer? _blinkTimer;

  void _onStartPressed() {
    setState(() {
      _startEnabled = false;
      _moveEnabled = true;
      _dropEnabled = false;
      _retryEnabled = false;
    });
  }

  void _onMovePressed() {
    if (_blinkTimer != null && _blinkTimer!.isActive) {
      _blinkTimer!.cancel();
    }
    setState(() {
      _retryEnabled = false;
      _moveEnabled = false;
      _dropEnabled = true;
      _blinkTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
        setState(() {
          _pointColors[_currentPointIndex] = _pointColors[_currentPointIndex] == Colors.grey
              ? Colors.green
              : Colors.grey;
        });
      });
    });
  }

  void _onDropPressed() {
    setState(() {
      if (_blinkTimer != null && _blinkTimer!.isActive) {
        _blinkTimer!.cancel();
      }
      _pointColors[_currentPointIndex] = Colors.green;
      _lastDroppedIndex = _currentPointIndex;

      if (_currentPointIndex < 5) { // 0-5 因为有6个点
        _currentPointIndex++;
        _moveEnabled = true;
      } else {
        _moveEnabled = false;
      }

      _dropEnabled = false;
      _retryEnabled = true;
    });
  }

  void _onRetryPressed() {
    setState(() {
      if (_blinkTimer != null && _blinkTimer!.isActive) {
        _blinkTimer!.cancel();
      }
      _currentPointIndex = _lastDroppedIndex;
      _pointColors[_currentPointIndex] = Colors.grey;
      _retryEnabled = false;
      _moveEnabled = true;
      _dropEnabled = false;
    });
  }

  @override
  void dispose() {
    if (_blinkTimer != null) {
      _blinkTimer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Flower Page', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(120, 120),
              painter: FlowerVerticesPainter(pointColors: _pointColors),
            ),
            SizedBox(height: 40),
            _buildCustomButton('Start', _startEnabled, _onStartPressed, Color(0xFFD5CEA3)),
            SizedBox(height: 10),
            _buildCustomButton('Move', _moveEnabled, _onMovePressed, Color(0xFFD5CEA3)),
            SizedBox(height: 10),
            _buildCustomButton('Retry', _retryEnabled, _onRetryPressed, Color(0xFFD5CEA3)),
            SizedBox(height: 10),
            _buildCustomButton('Drop', _dropEnabled, _onDropPressed, Color(0xFFD5CEA3)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton(String text, bool enabled, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color : Colors.grey[300],
        foregroundColor: Colors.white,
        minimumSize: Size(200, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: enabled ? 5 : 0,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class FlowerVerticesPainter extends CustomPainter {
  final List<Color> pointColors;

  FlowerVerticesPainter({this.pointColors = const [Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey]});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 12
      ..style = PaintingStyle.fill;

    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double radius = size.width / 2;

    List<Offset> points = [];

    // Add the center point
    points.add(Offset(cx, cy));

    // Calculate the points of a regular pentagon (five points)
    for (int i = 0; i < 5; i++) {
      double angle = 2 * pi * i / 5 - pi / 2;
      double x = cx + radius * cos(angle);
      double y = cy + radius * sin(angle);
      points.add(Offset(x, y));
    }

    for (int i = 0; i < points.length; i++) {
      paint.color = pointColors[i];
      canvas.drawCircle(points[i], 10, paint); // Draw points as circles
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
