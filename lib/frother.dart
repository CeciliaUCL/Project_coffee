import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart'; // Import the configuration file
import 'adjustment_page.dart'; // Import the adjustment page

class FrotherPage extends StatefulWidget {
  @override
  _FrotherPageState createState() => _FrotherPageState();
}

class _FrotherPageState extends State<FrotherPage> {
  bool _showCircle = false;
  String? _selectedPattern;

  void _toggleCircle() {
    setState(() {
      _showCircle = !_showCircle;
    });
  }

  Future<void> _runCircle() async {
    setState(() {
      _selectedPattern = 'Circle';
    });
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/run_circle'), // Use baseUrl
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
    setState(() {
      _selectedPattern = 'Square';
    });
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/run_square'), // Use baseUrl
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
    setState(() {
      _selectedPattern = 'Triangle';
    });
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/run_triangle'), // Use baseUrl
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
    setState(() {
      _selectedPattern = 'Star';
    });
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/run_star'), // Use baseUrl
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

  Future<void> _stop() async {
    final response = await http.post(
      Uri.parse('$baseUrl/stop'), // Use baseUrl
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

  void _navigateToAdjustmentPage() {
    if (_selectedPattern != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdjustmentPage(patternTitle: _selectedPattern!),
        ),
      );
    }
  }

  void _showConfirmationDialog(
      BuildContext context, String patternTitle, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Are you sure you want to run '$patternTitle'?"),
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
            'Choose Frother Pattern',
            style: TextStyle(color: Colors.black), // Set text color to black
          ),
        ),
        backgroundColor: Colors.transparent, // Set background color to transparent
        elevation: 0, // Remove shadow
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
                itemCount: 4, // Update the number of icons
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
                      patternIcon = Icons.star_border;
                      break;
                    default:
                      patternTitle = 'Pattern';
                      patternIcon = Icons.help_outline;
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Set background color to white
                      borderRadius: BorderRadius.circular(20.0), // Rounded borders
                      border: Border.all(color: Colors.black, width: 2), // Black, bold border
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
                          color: Colors.grey[700], // Set icon color
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _showConfirmationDialog(context, patternTitle, () {
                              if (index == 0) {
                                _runCircle();
                              } else if (index == 1) {
                                _runSquare();
                              } else if (index == 2) {
                                _runTriangle();
                              } else if (index == 3) {
                                _runStar();
                              } else {
                                _toggleCircle();
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD5CEA3), // Button color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10), // Smaller button
                            elevation: 10,
                            shadowColor: Colors.black.withOpacity(0.5),
                          ),
                          child: Text(
                            'Start',
                            style: TextStyle(
                                color: Colors.white, fontSize: 16), // Smaller button text
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200, // Fixed width, adjustable as needed
              child: ElevatedButton(
                onPressed: _navigateToAdjustmentPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD5CEA3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  elevation: 10,
                  shadowColor: Colors.black.withOpacity(0.5),
                ),
                child: Text(
                  'Adjust',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 200, // Same width as the above button
              child: ElevatedButton(
                onPressed: _stop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  elevation: 10,
                  shadowColor: Colors.black.withOpacity(0.5),
                ),
                child: Text(
                  'Stop',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: FrotherPage(),
    ));
