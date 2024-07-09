import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class LiquidVolumePage extends StatefulWidget {
  @override
  _LiquidVolumePageState createState() => _LiquidVolumePageState();
}

class _LiquidVolumePageState extends State<LiquidVolumePage> {
  double _currentVolume = 100.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentVolume();
  }

  _loadCurrentVolume() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentVolume = prefs.getDouble('selectedVolume') ?? 100.0;
    });
  }

  _saveCurrentVolume() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('selectedVolume', _currentVolume);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Liquid volume'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_currentVolume.round()} ml',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD5CEA3),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: CircularSliderPainter(_currentVolume),
                  child: Center(
                    child: Transform.rotate(
                      angle: math.pi / 2,
                      child: Slider(
                        value: _currentVolume,
                        min: 100,
                        max: 300,
                        onChanged: (value) {
                          setState(() {
                            _currentVolume = value;
                          });
                        },
                        activeColor: Color(0xFFD5CEA3),
                        inactiveColor: Colors.grey[300],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  '100 ml',
                  style: TextStyle(fontSize: 18), // 调大字体
                ),
                Text(
                  '300 ml',
                  style: TextStyle(fontSize: 18), // 调大字体
                ),
              ],
            ),
            Spacer(),
            Center(
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Color(0xFFD5CEA3), Color(0xFFD5CEA3)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _saveCurrentVolume();
                    Navigator.pop(context); // 返回上一页
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularSliderPainter extends CustomPainter {
  final double volume;
  CircularSliderPainter(this.volume);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final Paint progressPaint = Paint()
      ..color = Color(0xFFD5CEA3)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, paint);
    final double sweepAngle =
        2 * math.pi * (volume - 100) / (300 - 100); // 调整计算公式
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    final Offset knobPosition = Offset(
      center.dx + radius * math.cos(sweepAngle - math.pi / 2),
      center.dy + radius * math.sin(sweepAngle - math.pi / 2),
    );

    final Paint knobPaint = Paint()
      ..color = Color(0xFFD5CEA3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(knobPosition, 10, knobPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
