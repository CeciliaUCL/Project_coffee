import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart'; 

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
  bool _nextEnabled = false;
  List<Color> _pointColors = [Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey];
  Timer? _blinkTimer;

  bool isHardwareRunning = false;
  String _statusMessage = '';

  // Use Socket to send data
  Future<void> sendInputToServer(String text) async {
    try {
      final socket = await Socket.connect(socketUrl.split('//')[1].split(':')[0], int.parse(socketUrl.split(':')[2]));
      socket.write(text);
      await socket.close();
    } catch (e) {
      print("Failed to send data: $e");
    }
  }

  // Send a start request to the backend and pass command '5'
  Future<void> _startHardwareControl() async {
    final startTime = DateTime.now().millisecondsSinceEpoch;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/run_program'),
        body: json.encode({'start_time': startTime}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final backendTime = data['backend_time'];  // Time taken by the back-end

        final clientEndTime = DateTime.now().millisecondsSinceEpoch;
        final frontEndTime = clientEndTime - startTime;
        final totalTime = backendTime + frontEndTime;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Program started! Total time: ${totalTime}ms'),
        ));

        setState(() {
          isHardwareRunning = true;
          _statusMessage = 'You can place the particle, when it is ready you can press Move button.';
          _startEnabled = false;
          _moveEnabled = true;
          _dropEnabled = false;
          _retryEnabled = false;
          _nextEnabled = false;
        });

        await Future.delayed(Duration(seconds: 2)); 
        await sendInputToServer('5');  // Sending 'T' command
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to start program.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error starting program.')));
    }
  }

  // Send a stop request to the backend
  Future<void> _stopHardwareControl() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/stop_hardware_control'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Program stopped successfully!')));
        setState(() {
          isHardwareRunning = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to stop program.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error stopping program.')));
    }
  }

  // Send stop command when the user navigates back to the previous page
  Future<bool> _onWillPop() async {
    if (isHardwareRunning) {
      await sendInputToServer('x');  // Send 'x' command to stop the program
      await _stopHardwareControl();
    }
    return true;
  }

  // Function to control movement
  Future<void> _runMove() async {
    if (isHardwareRunning) await sendInputToServer('y');
  }

  Future<void> _runRetry() async {
    if (isHardwareRunning) await sendInputToServer('n');
  }

  Future<void> _runDrop() async {
    if (isHardwareRunning) await sendInputToServer('p');
  }

  Future<void> _runNext() async {
    if (isHardwareRunning) await sendInputToServer('y');
  }

  void _onStartPressed() {
    _startHardwareControl();
  }

  void _onMovePressed() {
    if (_blinkTimer != null && _blinkTimer!.isActive) {
      _blinkTimer!.cancel();
    }
    _runMove();  // Send 'y' command
    setState(() {
      _moveEnabled = false;
      _dropEnabled = true;
      _statusMessage = '';
    });
  }

  void _onDropPressed() {
    _runDrop();  // Send 'p' command
    setState(() {
      if (_blinkTimer != null && _blinkTimer!.isActive) {
        _blinkTimer!.cancel();
      }
      _pointColors[_currentPointIndex] = Colors.green;
      _lastDroppedIndex = _currentPointIndex;

      _moveEnabled = false;
      _dropEnabled = false;
      _nextEnabled = true;
      _retryEnabled = true;
    });
  }

  void _onNextPressed() {
    _runNext();  // Send 'y' command
    setState(() {
      if (_currentPointIndex < 5) {
        _currentPointIndex++;
        _moveEnabled = true;
        _nextEnabled = false;
        _retryEnabled = false;
        _statusMessage = 'You can place the particle, when it is ready you can press Move button.';
      } else {
        _moveEnabled = false;
        _nextEnabled = false;
        _retryEnabled = false;
        _statusMessage = 'All particles have been placed.';
      }
    });
  }

  void _onRetryPressed() {
    _runRetry();  // Send 'n' command
    setState(() {
      _nextEnabled = false;
      _retryEnabled = false;
      _moveEnabled = true;
      _statusMessage = 'You can place the particle, when it is ready you can press Move button.';
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
    return WillPopScope(
      onWillPop: _onWillPop,  // Intercept back operation to ensure the program is stopped on exit
      child: Scaffold(
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
              _buildStatusMessage(_statusMessage),
              SizedBox(height: 20),
              _buildCustomButton('Start', _startEnabled, _onStartPressed, Color(0xFFD5CEA3)),
              SizedBox(height: 10),
              _buildCustomButton('Move', _moveEnabled, _onMovePressed, Color(0xFFD5CEA3)),
              SizedBox(height: 10),
              _buildCustomButton('Drop', _dropEnabled, _onDropPressed, Color(0xFFD5CEA3)),
              SizedBox(height: 10),
              _buildCustomButton('Next', _nextEnabled, _onNextPressed, Color(0xFFD5CEA3)),
              SizedBox(height: 10),
              _buildCustomButton('Retry', _retryEnabled, _onRetryPressed, Color(0xFFD5CEA3)),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build status messages
  Widget _buildStatusMessage(String message) {
    if (message.isEmpty) {
      return Container();  // Do not display if message is empty
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blue[800]),
        textAlign: TextAlign.center,
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

    // Remove the center point, keep only the five vertices of the pentagon
    for (int i = 0; i < 5; i++) {
      double angle = 2 * pi * i / 5 - pi / 2;
      double x = cx + radius * cos(angle);
      double y = cy + radius * sin(angle);
      points.add(Offset(x, y));
    }

    for (int i = 0; i < points.length; i++) {
      paint.color = pointColors[i];
      canvas.drawCircle(points[i], 10, paint); // Draw the vertices of the pentagon
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
