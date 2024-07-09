import 'dart:convert';
import 'package:http/http.dart' as http;

class StartService {
  final String iftttUrl = 'https://nine-mails-lose.loca.lt/start_coffee_machine';

  Future<void> startCoffeeMachine(String coffeeType, String strength, int fillQuantity) async {
    final response = await http.post(
      Uri.parse(iftttUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'value1': coffeeType,
        'value2': strength,
        'value3': fillQuantity.toString(),
      }),
    );

    if (response.statusCode == 200) {
      print('Coffee machine started successfully');
    } else {
      print('Failed to start coffee machine: ${response.body}');
    }
  }
}
