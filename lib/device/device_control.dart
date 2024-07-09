import 'package:flutter/material.dart';

class MyDevicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Device Page'),
      ),
      body: Center(
        child: Text('This is the device control page.'),
      ),
    );
  }
}
