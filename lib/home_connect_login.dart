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
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Connect Authentication'),
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: 'https://simulator.home-connect.com/security/oauth/authorize?response_type=code&client_id=80840A20EDD4AC02F079C0B7493FB2BC6BCC7862D4BBB13D9688894A3438D983&redirect_uri=https://webhook.site/393b00e2-e865-4b69-a460-cff142b5937d&scope=IdentifyAppliance%20Monitor%20Control',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _webViewController = webViewController;
            },
            navigationDelegate: (NavigationRequest request) async {
              final Uri uri = Uri.parse(request.url);
              final String? code = uri.queryParameters['code'];
              final String? error = uri.queryParameters['error'];

              if (code != null) {
                await _exchangeCodeForToken(code);
                Navigator.pop(context, true);
                return NavigationDecision.prevent;
              } else if (error != null) {
                Navigator.pop(context, false);
                return NavigationDecision.prevent;
              }

              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              setState(() {
                isLoading = true;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(),
        ],
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
