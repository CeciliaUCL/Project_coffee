import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StrengthPage extends StatefulWidget {
  @override
  _StrengthPageState createState() => _StrengthPageState();
}

class _StrengthPageState extends State<StrengthPage> {
  List<String> strengths = [
    'Very Mild',
    'Mild',
    'Normal',
    'Strong',
    'Very Strong',
    'Double Shot',
    'Double Shot+',
    'Double Shot++'
  ];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSelectedStrength();
  }

  _loadSelectedStrength() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('selectedStrengthIndex') ?? 0;
    });
  }

  _saveSelectedStrength() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedStrengthIndex', _selectedIndex);
    prefs.setString('selectedStrength', strengths[_selectedIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Strength'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${strengths[_selectedIndex]}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: ListWheelScrollView(
                  itemExtent: 50,
                  diameterRatio: 1.5,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  children: strengths
                      .map((strength) => Center(child: Text(strength)))
                      .toList(),
                ),
              ),
            ),
            Spacer(),
            Center(
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFFD5CEA3), // 设置按钮颜色
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _saveSelectedStrength();
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
