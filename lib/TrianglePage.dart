import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'config.dart'; 

class TrianglePage extends StatefulWidget {
  @override
  _TrianglePageState createState() => _TrianglePageState();
}

class _TrianglePageState extends State<TrianglePage> {
  int _currentPointIndex = 0;
  int _lastDroppedIndex = -1;
  bool _startEnabled = true;
  bool _moveEnabled = false;
  bool _retryEnabled = false;
  bool _dropEnabled = false;
  bool _nextEnabled = false;  // 新增Next按钮的状态
  List<Color> _pointColors = [Colors.grey, Colors.grey, Colors.grey];
  Timer? _blinkTimer;

  bool isHardwareRunning = false;
  String _statusMessage = '';

  // 使用Socket发送数据
  Future<void> sendInputToServer(String text) async {
    try {
      final socket = await Socket.connect(socketUrl.split('//')[1].split(':')[0], int.parse(socketUrl.split(':')[2]));
      socket.write(text);
      await socket.close();
    } catch (e) {
      print("Failed to send data: $e");
    }
  }

  // 发送启动请求到后端，并传递命令 'T'
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

        // Calculate the front-end time (communication time)
        final clientEndTime = DateTime.now().millisecondsSinceEpoch;
        final frontEndTime = clientEndTime - startTime;

        // Calculate the total time: backend time + front-end time
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
        await sendInputToServer('T');  // Sending 'T' command
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to start program.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error starting program.')));
    }
  }

  // 发送停止请求到后端 
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

  // 在用户返回上一页时发送终止命令
  Future<bool> _onWillPop() async {
    if (isHardwareRunning) {
      await sendInputToServer('x');  // 发送 'x' 命令终止程序
      await _stopHardwareControl();
    }
    return true;  // 允许页面返回
  }

  // 控制方向的功能函数
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
    _runMove();  // 发送 'y' 命令
    setState(() {
      _moveEnabled = false;
      _dropEnabled = true;
      _statusMessage = '';
    });
  }

  void _onDropPressed() {
    _runDrop();  // 发送 'p' 命令
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
    _runNext();  // 发送 'y' 命令
    setState(() {
      if (_currentPointIndex < 2) {
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
    _runRetry();  // 发送 'n' 命令
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
      onWillPop: _onWillPop,  
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Triangle Page', style: TextStyle(color: Colors.black)),
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
                painter: TriangleVerticesPainter(pointColors: _pointColors),
              ),
              SizedBox(height: 40),
              // 美化提示框
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

  
  Widget _buildStatusMessage(String message) {
    if (message.isEmpty) {
      return Container(); 
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

class TriangleVerticesPainter extends CustomPainter {
  final List<Color> pointColors;

  TriangleVerticesPainter({this.pointColors = const [Colors.grey, Colors.grey, Colors.grey]});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 12
      ..style = PaintingStyle.fill;

    final points = [
      Offset(size.width / 2, 20),
      Offset(size.width - 20, size.height - 20),
      Offset(20, size.height - 20),
    ];

    for (int i = 0; i < points.length; i++) {
      paint.color = pointColors[i];
      canvas.drawCircle(points[i], 10, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
