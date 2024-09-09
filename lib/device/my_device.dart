import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_first_app/config.dart';

class MyDevicePage extends StatefulWidget {
  @override
  _MyDevicePageState createState() => _MyDevicePageState();
}

class _MyDevicePageState extends State<MyDevicePage> {
  double _selectedVolume = 130.0;
  String _selectedStrength = 'Normal';
  String _selectedCategory = 'Coffee';

  final String flaskServerUrl = '$baseUrl/start_coffee_machine';

  Map<String, Map<String, dynamic>> coffeeLiquidRanges = {
    'Espresso': {'min': 35, 'max': 40, 'step': 5},
    'Espresso Macchiato': {'min': 40, 'max': 60, 'step': 5},
    'Coffee': {'min': 60, 'max': 250, 'step': 10},
    'Cappuccino': {'min': 100, 'max': 300, 'step': 10},
    'Latte Macchiato': {'min': 200, 'max': 400, 'step': 10},
    'Coffee Lattee': {'min': 100, 'max': 400, 'step': 10},
  };

  Map<String, IconData> coffeeIcons = {
    'Espresso': Icons.local_cafe,
    'Espresso Macchiato': Icons.local_drink,
    'Coffee': Icons.coffee,
    'Cappuccino': Icons.local_cafe_outlined,
    'Latte Macchiato': Icons.free_breakfast,
    'Coffee Lattee': Icons.coffee_maker,
  };

  @override
  void initState() {
    super.initState();
    _loadSelectedVolume();
    _loadSelectedStrength();
    _loadSelectedCategory();
  }

  _loadSelectedVolume() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedVolume = prefs.getDouble('selectedVolume') ?? 130.0;
    });
  }

  _loadSelectedStrength() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedStrength = prefs.getString('selectedStrength') ?? 'Normal';
    });
  }

  _loadSelectedCategory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCategory = prefs.getString('selectedCategory') ?? 'Coffee';
      _updateVolumeRange();
    });
  }

  void _updateVolumeRange() {
    var range = coffeeLiquidRanges[_selectedCategory];
    if (range != null) {
      if (_selectedVolume < range['min']) {
        _selectedVolume = range['min'].toDouble();
      } else if (_selectedVolume > range['max']) {
        _selectedVolume = range['max'].toDouble();
      }
    }
  }

  void _triggerCoffeeMachine() async {
    try {
      final response = await http.post(
        Uri.parse(flaskServerUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'coffee_type': Uri.encodeComponent(_selectedCategory),
          'fill_quantity': _selectedVolume,
          'strength': Uri.encodeComponent(_selectedStrength),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Coffee machine started successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to start coffee machine.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    var range = coffeeLiquidRanges[_selectedCategory];
    var icon = coffeeIcons[_selectedCategory];

    if (range == null || icon == null) {
      return Center(
        child: Text('Invalid coffee type selected.'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: Text('My Coffee Machine'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Coffee Type Selection
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Coffee Type:', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                      DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down),
                        items: coffeeLiquidRanges.keys.map((String key) {
                          return DropdownMenuItem<String>(
                            value: key,
                            child: Row(
                              children: [
                                Icon(coffeeIcons[key]),
                                SizedBox(width: 10),
                                Text(key),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                            _updateVolumeRange();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Liquid Volume Selection
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Liquid Volume:', style: TextStyle(fontSize: 18)),
                      Slider(
                        value: _selectedVolume,
                        min: range['min'].toDouble(),
                        max: range['max'].toDouble(),
                        divisions: (range['max'] - range['min']) ~/ range['step'],
                        label: '${_selectedVolume.round()} ml',
                        onChanged: (value) {
                          setState(() {
                            _selectedVolume = value;
                          });
                        },
                      ),
                      Center(
                        child: Text(
                          '${_selectedVolume.round()} ml',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Strength Selection
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Strength:', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildStrengthButton('Very Mild'),
                          _buildStrengthButton('Mild'),
                          _buildStrengthButton('Normal'),
                          _buildStrengthButton('Strong'),
                          _buildStrengthButton('Very Strong'),
                          _buildStrengthButton('Double Shot'),
                          _buildStrengthButton('Double Shot+'),
                          _buildStrengthButton('Double Shot++'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),

              Center(
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton(
                    onPressed: _triggerCoffeeMachine,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor, // 使用默认的Flutter主题颜色
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Start',
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
      ),
    );
  }

  Widget _buildStrengthButton(String strength) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedStrength = strength;
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: _selectedStrength == strength ? Colors.white : Colors.black, 
        backgroundColor: _selectedStrength == strength ? Theme.of(context).primaryColor : Colors.white,
        elevation: 2,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(strength),
    );
  }
}
