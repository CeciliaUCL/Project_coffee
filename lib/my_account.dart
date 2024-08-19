import 'package:flutter/material.dart';
import 'package:my_first_app/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAccountPage extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }

  Future<Map<String, String>> _getAccountDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('userName');
    String? email = prefs.getString('email');
    return {
      'userName': userName ?? 'Unknown User',
      'email': email ?? 'Unknown Email'
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _getAccountDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading account details'));
        } else {
          var accountDetails = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('User: ${accountDetails['userName']}'),
                Text('Email: ${accountDetails['email']}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _logout(context),
                  child: Text('Logout'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
