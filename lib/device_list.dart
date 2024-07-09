import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_connect_login.dart';

class DeviceList extends StatefulWidget {
  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  bool isConnected = false;
  String userName = 'User';
  List<String> devices = [];

  @override
  void initState() {
    super.initState();
    checkAuthorization();
  }

  Future<void> checkAuthorization() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('accessToken');

    if (storedToken == null) {
      setState(() {
        isConnected = false;
      });
    } else {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/get_devices'),
        headers: <String, String>{
          'Authorization': 'Bearer $storedToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isConnected = true;
          userName = 'Yating'; // 替换为实际获取的用户名
          fetchDevices(storedToken);
        });
      } else {
        setState(() {
          isConnected = false;
        });
      }
    }
  }

  Future<void> fetchDevices(String accessToken) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/get_devices'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> devicesJson = jsonDecode(response.body)['data']['homeappliances'];
      List<String> devicesList = devicesJson.map((device) => device['name'].toString()).toList();
      setState(() {
        devices = devicesList;
      });
    } else {
      print('Failed to fetch devices');
    }
  }

  void navigateToLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeConnectLogin()),
    );

    if (result == true) {
      checkAuthorization();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Device'),
      ),
      body: isConnected ? _buildConnectedView() : _buildDisconnectedView(),
    );
  }

  Widget _buildConnectedView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hello, $userName!',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              return _buildDeviceTile(devices[index], 'SIEMENS');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceTile(String deviceName, String brand) {
    return ListTile(
      leading: Icon(Icons.coffee_maker),
      title: Text(deviceName),
      subtitle: Text(brand),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              // 实现设备开启逻辑
            },
            child: Text('Open'),
          ),
          TextButton(
            onPressed: () {
              // 实现设备演示逻辑
            },
            child: Text('Control'),
          ),
        ],
      ),
    );
  }

  Widget _buildDisconnectedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No Available Device',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: navigateToLogin,
            child: Text('Login via Home Connect'),
          ),
        ],
      ),
    );
  }
}
