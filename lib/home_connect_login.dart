import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeConnectLogin extends StatefulWidget {
  @override
  _HomeConnectLoginState createState() => _HomeConnectLoginState();
}

class _HomeConnectLoginState extends State<HomeConnectLogin> {
  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Connect Authentication'),
      ),
      body: WebView(
        initialUrl: 'https://simulator.home-connect.com/security/oauth/authorize?response_type=code&client_id=2834200440E227B1C1DAF6687F0D3E4B56AEBAAB281F02D37B3266CB4BE6BB3E&scope=IdentifyAppliance%20Monitor%20Control',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;
        },
        navigationDelegate: (NavigationRequest request) async {
          if (request.url.contains('code=')) {
            final Uri uri = Uri.parse(request.url);
            final String? code = uri.queryParameters['code'];
            if (code != null) {
              await _exchangeCodeForToken(code);
              Navigator.pop(context, true);
            }
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }

  Future<void> _exchangeCodeForToken(String code) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/token'),
      body: {'code': code},
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );
    if (response.statusCode == 200) {
      String newToken = jsonDecode(response.body)['access_token'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('accessToken', newToken);
    } else {
      print('Failed to get access token');
    }
  }
}
