import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart'; // 导入配置文件

class SprinklePage extends StatefulWidget {
  @override
  _SprinklePageState createState() => _SprinklePageState();
}

class _SprinklePageState extends State<SprinklePage> {
  bool _showCircle = false;

  void _toggleCircle() {
    setState(() {
      _showCircle = !_showCircle;
    });
  }

  Future<void> _runCircle() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/run_circle'), // 使用 baseUrl
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Output: ${data['output']}');
        print('Error: ${data['error']}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Circle command sent successfully!'),
        ));
      } else {
        print('Failed to run code: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to run circle command.'),
        ));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error running circle command.'),
      ));
    }
  }

  Future<void> _runSquare() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/run_square'), // 使用 baseUrl
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Output: ${data['output']}');
        print('Error: ${data['error']}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Square command sent successfully!'),
        ));
      } else {
        print('Failed to run code: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to run square command.'),
        ));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error running square command.'),
      ));
    }
  }

  Future<void> _runTriangle() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/run_triangle'), // 使用 baseUrl
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Output: ${data['output']}');
        print('Error: ${data['error']}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Triangle command sent successfully!'),
        ));
      } else {
        print('Failed to run code: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to run triangle command.'),
        ));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error running triangle command.'),
      ));
    }
  }

  Future<void> _runStar() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/run_star'), // 使用 baseUrl
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Output: ${data['output']}');
        print('Error: ${data['error']}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Star command sent successfully!'),
        ));
      } else {
        print('Failed to run code: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to run star command.'),
        ));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error running star command.'),
      ));
    }
  }

  Future<void> _runHeart() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/run_heart'), // 使用 baseUrl
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Output: ${data['output']}');
        print('Error: ${data['error']}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Heart command sent successfully!'),
        ));
      } else {
        print('Failed to run code: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to run heart command.'),
        ));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error running heart command.'),
      ));
    }
  }

  Future<void> _runCloud() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/run_cloud'), // 使用 baseUrl
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Output: ${data['output']}');
        print('Error: ${data['error']}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Cloud command sent successfully!'),
        ));
      } else {
        print('Failed to run code: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to run cloud command.'),
        ));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error running cloud command.'),
      ));
    }
  }

  Future<void> _stop() async {
    final response = await http.post(
      Uri.parse('$baseUrl/stop'), // 使用 baseUrl
    );

    if (response.statusCode == 200) {
      print('Process stopped successfully');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Process stopped successfully!'),
      ));
    } else {
      print('Failed to stop process: ${response.reasonPhrase}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to stop process.'),
      ));
    }
  }

  void _showConfirmationDialog(
      BuildContext context, String patternTitle, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Are you sure you want to print '$patternTitle'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Choose Sprinkle Pattern',
            style: TextStyle(color: Colors.black), // 设置文字颜色为黑色
          ),
        ),
        backgroundColor: Colors.transparent, // 设置背景颜色为透明
        elevation: 0, // 移除阴影
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 6, // 修改为6个项目
                itemBuilder: (context, index) {
                  String patternTitle;
                  IconData patternIcon;
                  switch (index) {
                    case 0:
                      patternTitle = 'Circle';
                      patternIcon = Icons.circle_outlined;
                      break;
                    case 1:
                      patternTitle = 'Square';
                      patternIcon = Icons.crop_square;
                      break;
                    case 2:
                      patternTitle = 'Triangle';
                      patternIcon = Icons.change_history;
                      break;
                    case 3:
                      patternTitle = 'Star';
                      patternIcon = Icons.star_border_outlined;
                      break;
                    case 4:
                      patternTitle = 'Heart';
                      patternIcon = Icons.favorite_border;
                      break;
                    case 5:
                      patternTitle = 'Cloud';
                      patternIcon = Icons.cloud_queue;
                      break;
                    default:
                      patternTitle = 'Pattern';
                      patternIcon = Icons.help_outline;
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // 背景颜色为白色
                      borderRadius: BorderRadius.circular(20.0), // 边框圆角
                      border: Border.all(color: Colors.black, width: 2), // 黑色加粗边框
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          patternTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Icon(
                          patternIcon,
                          size: 80,
                          color: Colors.grey[700], // 设置图标颜色
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _showConfirmationDialog(context, patternTitle, () {
                              if (index == 0) {
                                _runCircle();
                              } else if(index==1){
                                _runSquare();
                              }else if(index==2){
                                _runTriangle();
                              }else if(index==3){
                                _runStar();
                              }else if(index==4){
                                _runHeart();
                              }else if(index==5){
                                _runCloud();
                              }else{
                                _toggleCircle();
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD5CEA3), // 按钮颜色
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10), // 按钮变小
                            elevation: 10,
                            shadowColor: Colors.black.withOpacity(0.5),
                          ),
                          child: Text(
                            'Start',
                            style: TextStyle(
                                color: Colors.white, fontSize: 16), // 按钮文字稍微小一点
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stop,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // 设置按钮颜色为红色
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.5),
              ),
              child: Text(
                'Stop',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
