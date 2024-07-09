import 'dart:convert';
import 'package:http/http.dart' as http;

class StopService {
  final String iftttUrl = 'YOUR_IFTTT_WEBHOOK_URL_FOR_STOP';

  Future<void> stopCoffeeMachine() async {
    final response = await http.post(
      Uri.parse(iftttUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'value1': 'stop',
      }),
    );

    if (response.statusCode == 200) {
      print('Coffee machine stopped successfully');
    } else {
      print('Failed to stop coffee machine: ${response.body}');
    }
  }
}
