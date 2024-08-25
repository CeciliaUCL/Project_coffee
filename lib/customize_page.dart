import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_first_app/config.dart';  // 确保你的配置文件中有正确的baseUrl

class CustomizePage extends StatefulWidget {
  @override
  _CustomizePageState createState() => _CustomizePageState();
}

class _CustomizePageState extends State<CustomizePage> {
  bool isHardwareRunning = false;

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

  // 发送启动请求到后端
  Future<void> _startHardwareControl() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/run_program'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Program started successfully!')));
        setState(() {
          isHardwareRunning = true;
        });
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

  // 控制方向的功能函数
  Future<void> _runForward() async {
    if (isHardwareRunning) await sendInputToServer('w');
  }

  Future<void> _runBackward() async {
    if (isHardwareRunning) await sendInputToServer('s');
  }

  Future<void> _runLeft() async {
    if (isHardwareRunning) await sendInputToServer('a');
  }

  Future<void> _runRight() async {
    if (isHardwareRunning) await sendInputToServer('d');
  }

  Future<void> _runUp() async {
    if (isHardwareRunning) await sendInputToServer('q');
  }

  Future<void> _runDown() async {
    if (isHardwareRunning) await sendInputToServer('e');
  }

  // 放置颗粒的功能
  Future<void> _dropParticles() async {
    if (isHardwareRunning) {
      await sendInputToServer('x');
      await Future.delayed(Duration(seconds: 1));
      await _stopHardwareControl();
    }
  }

  @override
  void dispose() {
    _dropParticles();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,  // 标题居中
        title: Text(
          'Customize Page',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isHardwareRunning ? null : _startHardwareControl,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        backgroundColor: isHardwareRunning ? Colors.grey : Color(0xFFD5CEA3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Text('Start', style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isHardwareRunning ? _dropParticles : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        backgroundColor: isHardwareRunning ? Color(0xFFD5CEA3) : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Text('Drop', style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              _buildDirectionalButton(Icons.arrow_upward, _runForward, isHardwareRunning),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDirectionalButton(Icons.arrow_back, _runLeft, isHardwareRunning),
                  SizedBox(width: 20),
                  _buildDirectionalButton(Icons.arrow_forward, _runRight, isHardwareRunning),
                ],
              ),
              _buildDirectionalButton(Icons.arrow_downward, _runBackward, isHardwareRunning),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isHardwareRunning ? _runUp : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        backgroundColor: isHardwareRunning ? Color(0xFFD5CEA3) : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Text('Up', style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isHardwareRunning ? _runDown : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        backgroundColor: isHardwareRunning ? Color(0xFFD5CEA3) : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Text('Down', style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionalButton(IconData icon, VoidCallback onPressed, bool enabled) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      child: Icon(icon, size: 50, color: enabled ? Colors.grey[800] : Colors.grey),
    );
  }
}
