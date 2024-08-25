import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'customize_page.dart';
import 'dart:math';
import 'TrianglePage.dart';
import 'SquarePage.dart';
import 'HexagonPage.dart';
import 'FlowerPage.dart';

class SprinklePage extends StatefulWidget {
  @override
  _SprinklePageState createState() => _SprinklePageState();
}

class _SprinklePageState extends State<SprinklePage> {
  Future<void> _stop() async {
    // 停止操作的实现逻辑
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

  void _navigateToCustomizePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomizePage()),
    );
  }

  void _navigateToTrianglePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TrianglePage()),
    );
  }
 void _navigateToSquarePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SquarePage()),
    );
  } void _navigateToHexagonPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HexagonPage()),
    );
  } void _navigateToFlowerPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FlowerPage()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Choose Sprinkle Pattern',
            style: TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                itemCount: 4,
                itemBuilder: (context, index) {
                  String patternTitle;
                  Widget patternIcon;
                  switch (index) {
                    case 0:
                      patternTitle = 'Triangle';
                      patternIcon = CustomPaint(
                        size: Size(50, 50), // 缩小图像尺寸
                        painter: TriangleVerticesPainter(),
                      );
                      break;
                    case 1:
                      patternTitle = 'Square';
                      patternIcon = CustomPaint(
                        size: Size(50, 50), // 缩小图像尺寸
                        painter: SquareVerticesPainter(),
                      );
                      break;
                    case 2:
                      patternTitle = 'Hexagon';
                      patternIcon = CustomPaint(
                        size: Size(50, 50), // 缩小图像尺寸
                        painter: HexagonVerticesPainter(),
                      );
                      break;
                    case 3:
                      patternTitle = 'Star';
                       patternIcon = CustomPaint(
                        size: Size(50, 50), // 缩小图像尺寸
                        painter: FlowerVerticesPainter(),
                      );
                      break;
                    default:
                      patternTitle = 'Pattern';
                      patternIcon = Icon(Icons.help_outline, size: 50, color: Colors.grey[700]); // 缩小图标
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Colors.black, width: 2),
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
                        patternIcon,
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _showConfirmationDialog(context, patternTitle, () {
                              if (index == 0) {
                                _navigateToTrianglePage();
                              } else if (index == 1) {
                                _navigateToSquarePage();
                              } else if (index == 2) {
                                _navigateToHexagonPage();
                              } else if (index == 3) {
                                _navigateToFlowerPage();
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD5CEA3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            elevation: 10,
                            shadowColor: Colors.black.withOpacity(0.5),
                          ),
                          child: Text(
                            'Start',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _navigateToCustomizePage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      elevation: 10,
                      shadowColor: Colors.black.withOpacity(0.5),
                    ),
                    child: Text(
                      'Customize',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _stop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TriangleVerticesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 10
      ..style = PaintingStyle.fill;

    final points = [
      Offset(size.width / 2, 0),
      Offset(size.width, size.height),
      Offset(0, size.height),
    ];

    for (var point in points) {
      canvas.drawCircle(point, 3, paint); // 缩小点的大小
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class SquareVerticesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 10
      ..style = PaintingStyle.fill;

    final points = [
      Offset(0, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];

    for (var point in points) {
      canvas.drawCircle(point, 3, paint); // 缩小点的大小
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class HexagonVerticesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 10
      ..style = PaintingStyle.fill;

    final points = [
      Offset(size.width * 0.5, 0),
      Offset(size.width, size.height * 0.25),
      Offset(size.width, size.height * 0.75),
      Offset(size.width * 0.5, size.height),
      Offset(0, size.height * 0.75),
      Offset(0, size.height * 0.25),
    ];

    for (var point in points) {
      canvas.drawCircle(point, 3, paint); // 缩小点的大小
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}


class FlowerVerticesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 10
      ..style = PaintingStyle.fill;

    // Calculate the points of a regular pentagon
    double cx = size.width / 2;
    double cy = size.height / 2;
    double radius = size.width / 2;

    List<Offset> points = [];
    for (int i = 0; i < 5; i++) {
      double angle = 2 * pi * i / 5 - pi / 2;
      double x = cx + radius * cos(angle);
      double y = cy + radius * sin(angle);
      points.add(Offset(x, y));
    }

    // Draw the pentagon vertices
    for (var point in points) {
      canvas.drawCircle(point, 3, paint); // Small circles for vertices
    }

    // Draw the center point
    canvas.drawCircle(Offset(cx, cy), 3, paint); // Center point
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

