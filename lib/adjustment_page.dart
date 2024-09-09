import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart'; // Import configuration file

// The state class for the adjustment page, responsible for managing the page's state and logic
class AdjustmentPage extends StatefulWidget {
  final String patternTitle; // Store the pattern name passed from FrotherPage

  // Constructor that receives the pattern name as a parameter
  AdjustmentPage({required this.patternTitle});

  @override
  _AdjustmentPageState createState() => _AdjustmentPageState();
}

// Class responsible for handling user input and updating the UI state
class _AdjustmentPageState extends State<AdjustmentPage> {
  // Function to adjust the pattern position, accepts direction (up, down, left, right) as a parameter
  Future<void> _adjustPosition(String direction) async {
    try {
      // Send an HTTP POST request to the server to adjust the pattern position
      final response = await http.post(
        Uri.parse('$baseUrl/adjust_position'), // Use baseUrl
        body: json.encode({'direction': direction}), // Send the direction data
        headers: {'Content-Type': 'application/json'}, // Set the request headers to JSON
      );

      // Determine if the request was successful based on the server's status code
      if (response.statusCode == 200) {
        print('Position adjusted successfully');
        // Display a notification on the screen indicating successful adjustment
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Position adjusted: $direction'),
        ));
      } else {
        print('Failed to adjust position');
        // Display an error notification indicating that the adjustment failed
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to adjust position.'),
        ));
      }
    } catch (e) {
      print('Error: $e');
      // Display an error notification indicating there was an error sending the request
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error adjusting position.'),
      ));
    }
  }

  // Function to stop the current pattern
  Future<void> _stop() async {
    try {
      // Send an HTTP POST request to the server to stop the pattern
      final response = await http.post(
        Uri.parse('$baseUrl/stop'),
      );

      // Determine if the request was successful based on the server's status code
      if (response.statusCode == 200) {
        print('Process stopped successfully');
        // Display a notification on the screen indicating successful stopping
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Process stopped successfully!'),
        ));
      } else {
        print('Failed to stop process');
        // Display an error notification indicating the stopping process failed
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to stop process.'),
        ));
      }
    } catch (e) {
      print('Error: $e');
      // Display an error notification indicating there was an error sending the request
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error stopping process.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Adjust ${widget.patternTitle} Pattern'), // Display the current pattern name being adjusted in the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Vertically center the content
          children: [
            // The first row with only one upward arrow button to move the pattern up
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_upward, size: 50), // Upward arrow icon
                  onPressed: () =>
                      _adjustPosition('up'), // Call _adjustPosition function with 'up' as the parameter
                ),
              ],
            ),
            // The second row contains left, stop, and right buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, size: 50), // Left arrow icon
                  onPressed: () => _adjustPosition(
                      'left'), // Call _adjustPosition function with 'left' as the parameter
                ),
                IconButton(
                  icon: Icon(Icons.stop_circle,
                      color: Colors.red, size: 50), // Red stop button
                  onPressed: _stop, // Call _stop function to stop the pattern
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward, size: 50), // Right arrow icon
                  onPressed: () => _adjustPosition(
                      'right'), // Call _adjustPosition function with 'right' as the parameter
                ),
              ],
            ),
            // The third row with only one downward arrow button to move the pattern down
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_downward, size: 50), // Downward arrow icon
                  onPressed: () => _adjustPosition(
                      'down'), // Call _adjustPosition function with 'down' as the parameter
                ),
              ],
            ),
            SizedBox(height: 20), // Add some vertical spacing
            // Back button to return to the previous page
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Use Navigator.pop to return to the previous page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD5CEA3), // Set button color to blue
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.5),
              ),
              child: Text(
                'Back', // Text on the button
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
