import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sprinkling Page'),
        backgroundColor: Color(0xFF6F4E37), // 设置AppBar颜色为深咖啡色
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _toggleCircle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6F4E37), // 按钮颜色为深咖啡色
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.5),
              ),
              child: Text(
                'Print Circle',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            SizedBox(height: 30),
            if (_showCircle)
              AnimatedContainer(
                duration: Duration(seconds: 1),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0xFF6F4E37), Color(0xFFD7CCC8)],
                    center: Alignment(-0.3, -0.5),
                    radius: 1.0,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: SprinklePage(),
));
