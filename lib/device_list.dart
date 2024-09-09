import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'device/my_device.dart';
import 'home_connect_login.dart';
import 'config.dart';
import 'package:url_launcher/url_launcher.dart';  // Import url_launcher

class Device {
  final String name;
  final String brand;
  final bool connected;
  String get state => connected ? 'Connected' : 'Not Connected';

  Device({required this.name, required this.brand, required this.connected});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      name: json['name'] ?? 'Unknown',
      brand: json['brand'] ?? 'Unknown',
      connected: json['connected'] ?? false,
    );
  }
}

class DeviceList extends StatefulWidget {
  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  bool isConnected = false;
  String userName = 'User';
  List<Device> devices = [];

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
        Uri.parse('$baseUrl/get_devices'),
        headers: <String, String>{
          'Authorization': 'Bearer $storedToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isConnected = true;
          userName = 'A';
          fetchDevices();
        });
      } else {
        setState(() {
          isConnected = false;
        });
      }
    }
  }

  Future<void> fetchDevices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      setState(() {
        isConnected = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get_devices'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> devicesJson = jsonDecode(response.body)['data']['homeappliances'];
      List<Device> devicesList = devicesJson.map((device) => Device.fromJson(device)).toList();
      setState(() {
        devices = devicesList.where((device) => device.name.contains('Coffee')).toList();
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
      setState(() {
        checkAuthorization();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Authorization cancelled by user'),
      ));
    }
  }

  void redirectToSimulator() {
    const url = 'https://developer.home-connect.com/simulator'; // Adjust the URL as needed
    launchUrl(Uri.parse(url));
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
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return _buildDeviceTile(devices[index]);
      },
    );
  }

  Widget _buildDeviceTile(Device device) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.coffee_maker, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        device.brand,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('State: ${device.state}', style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: device.connected
                        ? null  // If the device is connected (ON), disable the Turn On button
                        : () {
                            redirectToSimulator();
                          },
                    child: Text('Turn On'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      backgroundColor: device.connected ? Colors.grey : Theme.of(context).primaryColor,  // Background color adjustment
                      foregroundColor: Colors.white,  // Set text color to white
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: device.connected
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MyDevicePage()),
                            ).then((_) {
                              setState(() {
                                checkAuthorization();
                              });
                            });
                          }
                        : null,  // If the device is not connected (OFF), disable the Control button
                    child: Text('Control'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: device.connected
                          ? Theme.of(context).primaryColor
                          : Colors.grey,  // Show grey when the button is disabled
                      padding: EdgeInsets.symmetric(vertical: 8),
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
