import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'categories_page.dart';
import 'liquid_volume_page.dart';
import 'strength_page.dart';
import 'dart:convert';
import 'package:uri/uri.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyDevicePageTest extends StatefulWidget {
  @override
  _MyDevicePageState createState() => _MyDevicePageState();
}

class _MyDevicePageState extends State<MyDevicePageTest> {
  double _selectedVolume = 130.0;
  String _selectedStrength = 'Normal';
  String _selectedCategory = 'Coffee';
  String? accessToken; // 将 accessToken 声明为 String?

  // 更新这里的Flask服务器URL
  final String flaskServerUrl = 'http://10.0.2.2:5000/start_coffee_machine'; // 如果使用Android模拟器
  final String authorizationUrl = 'http://10.0.2.2:5000/';
  final String tokenCheckUrl = 'http://10.0.2.2:5000/check_token';

  @override
  void initState() {
    super.initState();
    _loadSelectedVolume();
    _loadSelectedStrength();
    _loadSelectedCategory();
    _checkAuthorization(); // 检查授权状态
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
    });
  }

  Future<void> _checkAuthorization() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('accessToken');

    if (storedToken == null) {
      await _authenticate();
    } else {
      final response = await http.get(
        Uri.parse(tokenCheckUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $storedToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          accessToken = storedToken;
        });
      } else {
        await _authenticate();
      }
    }
  }

  Future<void> _authenticate() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebView(
          initialUrl: authorizationUrl,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith('http://10.0.2.2:5000/callback')) {
              final Uri uri = Uri.parse(request.url);
              final String? code = uri.queryParameters['code'];
              if (code != null) {
                _exchangeCodeForToken(code);
                Navigator.pop(context);
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }

  Future<void> _exchangeCodeForToken(String code) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/token'),
      body: {'code': code},
    );
    if (response.statusCode == 200) {
      String newToken = jsonDecode(response.body)['access_token'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('accessToken', newToken);

      setState(() {
        accessToken = newToken;
      });
    } else {
      print('Failed to get access token');
    }
  }

  void _triggerCoffeeMachine() async {
    if (accessToken == null) {
      await _authenticate();
    }

    if (accessToken != null) {
      try {
        final response = await http.post(
          Uri.parse(flaskServerUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(<String, dynamic>{
            'coffee_type': Uri.encodeComponent(_selectedCategory),
            'fill_quantity': _selectedVolume,
            'strength': Uri.encodeComponent(_selectedStrength),
          }),
        );

        if (response.statusCode == 200) {
          print('Coffee machine started successfully!');
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Coffee machine started successfully!')));
        } else {
          print('Failed to start coffee machine: ${response.statusCode}');
          print('Response: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to start coffee machine.')));
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('My Coffee Machine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.local_cafe),
              title: Text(_selectedCategory),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoriesPage()),
                ).then((_) => _loadSelectedCategory());
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.local_drink),
              title: Text('${_selectedVolume.round()} ml'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LiquidVolumePage()),
                ).then((_) => _loadSelectedVolume());
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.coffee_maker),
              title: Text(_selectedStrength),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StrengthPage()),
                ).then((_) => _loadSelectedStrength());
              },
            ),
            Divider(),
            Spacer(),
            Center(
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFFD5CEA3),
                ),
                child: ElevatedButton(
                  onPressed: _triggerCoffeeMachine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
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
    );
  }
}

