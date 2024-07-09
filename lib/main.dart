import 'package:flutter/material.dart';
import 'package:my_first_app/main_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
        primarySwatch: Colors.brown, // Use a predefined MaterialColor
      ),
      home: MainPage(),
    );
  }
}


