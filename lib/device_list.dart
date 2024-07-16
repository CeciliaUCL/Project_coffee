import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'device/my_device.dart';
import 'home_connect_login.dart';

class Device {
  final String name;
  final String brand;
  final bool connected;
  String get state => connected ? 'ON' : 'OFF';

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
        Uri.parse('http://10.0.2.2:5000/get_devices'),
        headers: <String, String>{
          'Authorization': 'Bearer $storedToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isConnected = true;
          userName = 'Yating';
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
      Uri.parse('http://10.0.2.2:5000/get_devices'),
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

  Future<void> powerOnSimulator() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      setState(() {
        isConnected = false;
      });
      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/power_on'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Simulator powered on successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to power on simulator')),
      );
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
                    onPressed: () {
                      powerOnSimulator();
                    },
                    child: Text('Open'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      print("Control button pressed for ${device.name}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyDevicePage()),
                      ).then((_) {
                        print("Returned from MyDevicePage");
                        setState(() {
                          checkAuthorization();
                        });
                      });
                    },
                    child: Text('Control'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor,
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
