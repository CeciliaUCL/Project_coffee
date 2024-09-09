// import 'dart:io';
// import 'package:flutter/material.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Flutter to EXE Input'),
//         ),
//         body: InputForm(),
//       ),
//     );
//   }
// }

// class InputForm extends StatefulWidget {
//   @override
//   _InputFormState createState() => _InputFormState();
// }

// class _InputFormState extends State<InputForm> {
//   final _controller = TextEditingController();

// void sendInputToServer(String text) async {
//   try {
//     // 使用10.0.2.2连接到主机的localhost
//     final socket = await Socket.connect('10.0.2.2', 8888);
//     print('Connected to server');
    
//     // 发送数据
//     socket.write(text);
//     print('Data sent to server: $text');
    
//     // 关闭连接
//     await socket.close();
//   } catch (e) {
//     print("Failed to send data: $e");
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: <Widget>[
//           TextField(
//             controller: _controller,
//             decoration: InputDecoration(labelText: 'Enter text'),
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               // 发送输入的数据到服务器
//               sendInputToServer(_controller.text);
//               _controller.clear();
//             },
//             child: Text('Send to EXE'),
//           ),
//         ],
//       ),
//     );
//   }
// }



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
        //primarySwatch: Colors.brown, // Use a predefined MaterialColor
      ),
      home: MainPage(),
    );
  }
}