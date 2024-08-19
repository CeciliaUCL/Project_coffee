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
      // 使用10.0.2.2连接到主机的localhost
      final socket = await Socket.connect(socketUrl.split('//')[1].split(':')[0], int.parse(socketUrl.split(':')[2]));
      print('Connected to server');
      
      // 发送数据
      socket.write(text);
      print('Data sent to server: $text');
      
      // 关闭连接
      await socket.close();
    } catch (e) {
      print("Failed to send data: $e");
    }
  }
  
  // 发送启动请求到后端
Future<void> _startHardwareControl() async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/run_program'), // 使用 baseUrl
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Message: ${data['message']}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Program started successfully!'),
      ));
      setState(() {
        isHardwareRunning = true;
      });
    } else {
      print('Failed to start program: ${response.reasonPhrase}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to start program.'),
      ));
    }
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error starting program.'),
    ));
  }
}
  // 发送停止请求到后端
  Future<void> _stopHardwareControl() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/stop_hardware_control'),
      );
      if (response.statusCode == 200) {
        print('Hardware control stopped');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Program stopped successfully!'),
        ));
        setState(() {
          isHardwareRunning = false;
        });
      } else {
        print('Failed to stop program: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to stop program.'),
        ));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error stopping program.'),
      ));
    }
  }


  Future<void> _runForward() async {
    if (isHardwareRunning) {
      await sendInputToServer('w');
    }
  }

  Future<void> _runBackward() async {
    if (isHardwareRunning) {
      await sendInputToServer('s');
    }
  }

  Future<void> _runLeft() async {
    if (isHardwareRunning) {
      await sendInputToServer('a');
    }
  }

  Future<void> _runRight() async {
    if (isHardwareRunning) {
      await sendInputToServer('d');
    }
  }

  Future<void> _runUp() async {
    if (isHardwareRunning) {
      await sendInputToServer('q');
    }
  }

  Future<void> _runDown() async {
    if (isHardwareRunning) {
      await sendInputToServer('e');
    }
  }

  Future<void> _dropParticles() async {
    if (isHardwareRunning) {
      await sendInputToServer('x');
      await Future.delayed(Duration(seconds: 1)); // 等待'x'字符被处理
      await _stopHardwareControl();
    }
  }

  Future<void> _recognizeReflector() async {
    // 实现识别反射器的功能
    print('Recognize Reflector button pressed');
  }

  @override
  void dispose() {
    _dropParticles(); // 停止并释放资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Customize Page',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _recognizeReflector,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  backgroundColor: Color(0xFFD5CEA3),
                ),
                child: Text('Recognize Reflector', style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isHardwareRunning ? null : _startHardwareControl,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        backgroundColor: isHardwareRunning ? Colors.grey : Color(0xFFD5CEA3),
                      ),
                      child: Text('Start', style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isHardwareRunning ? _dropParticles : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        backgroundColor: isHardwareRunning ? Color(0xFFD5CEA3) : Colors.grey,
                      ),
                      child: Text('Drop', style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isHardwareRunning ? _runForward : null,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Icon(Icons.arrow_upward, size: 50, color: isHardwareRunning ? Colors.grey[800] : Colors.grey),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isHardwareRunning ? _runLeft : null,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Icon(Icons.arrow_back, size: 50, color: isHardwareRunning ? Colors.grey[800] : Colors.grey),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: isHardwareRunning ? _runRight : null,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Icon(Icons.arrow_forward, size: 50, color: isHardwareRunning ? Colors.grey[800] : Colors.grey),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: isHardwareRunning ? _runBackward : null,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Icon(Icons.arrow_downward, size: 50, color: isHardwareRunning ? Colors.grey[800] : Colors.grey),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isHardwareRunning ? _runUp : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        backgroundColor: isHardwareRunning ? Color(0xFFD5CEA3) : Colors.grey,
                      ),
                      child: Text('Up', style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isHardwareRunning ? _runDown : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        backgroundColor: isHardwareRunning ? Color(0xFFD5CEA3) : Colors.grey,
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
}
