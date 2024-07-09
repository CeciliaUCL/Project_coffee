// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class FrotherPage extends StatefulWidget {
//   @override
//   _FrotherPageState createState() => _FrotherPageState();
// }

// class _FrotherPageState extends State<FrotherPage> {
//   bool _showCircle = false;

//   void _toggleCircle() {
//     setState(() {
//       _showCircle = !_showCircle;
//     });
//   }

//   Future<void> _runFrother() async {
//     final response = await http.post(
//       Uri.parse('http://172.20.10.6:5000/run_frother'), // 替换为你的本地IP地址
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       print('Output: ${data['output']}');
//       print('Error: ${data['error']}');
//     } else {
//       print('Failed to run frother: ${response.reasonPhrase}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Center(
//           child: Text(
//             'Choose Frother Pattern',
//             style: TextStyle(color: Colors.black), // 设置文字颜色为黑色
//           ),
//         ),
//         backgroundColor: Colors.transparent, // 设置背景颜色为透明
//         elevation: 0, // 移除阴影
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: GridView.builder(
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             childAspectRatio: 1,
//             crossAxisSpacing: 10,
//             mainAxisSpacing: 10,
//           ),
//           itemCount: 6, // 修改为6个项目
//           itemBuilder: (context, index) {
//             String patternTitle;
//             switch (index) {
//               case 0:
//                 patternTitle = 'Circle';
//                 break;
//               case 1:
//                 patternTitle = 'Square';
//                 break;
//               case 2:
//                 patternTitle = 'Triangle';
//                 break;
//               case 3:
//                 patternTitle = 'Star';
//                 break;
//               case 4:
//                 patternTitle = 'Heart';
//                 break;
//               case 5:
//                 patternTitle = 'Diamond';
//                 break;
//               default:
//                 patternTitle = 'Pattern';
//             }

//             return Container(
//               decoration: BoxDecoration(
//                 color: Colors.white, // 背景颜色为白色
//                 borderRadius: BorderRadius.circular(20.0), // 边框圆角
//                 border: Border.all(color: Colors.black, width: 2), // 黑色加粗边框
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     patternTitle,
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Container(
//                     width: 80,
//                     height: 80,
//                     color: Colors.grey[300], // Placeholder for image
//                   ),
//                   SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () {
//                       if (index == 0) {
//                         _runFrother();
//                       } else {
//                         _toggleCircle();
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFFD5CEA3), // 按钮颜色
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                       ),
//                       padding: EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 10), // 按钮变小
//                       elevation: 10,
//                       shadowColor: Colors.black.withOpacity(0.5),
//                     ),
//                     child: Text(
//                       'Start',
//                       style: TextStyle(
//                           color: Colors.white, fontSize: 16), // 按钮文字稍微小一点
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// void main() => runApp(MaterialApp(
//       home: FrotherPage(),
//     ));

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FrotherPage extends StatefulWidget {
  @override
  _FrotherPageState createState() => _FrotherPageState();
}

class _FrotherPageState extends State<FrotherPage> {
  bool _showCircle = false;

  void _toggleCircle() {
    setState(() {
      _showCircle = !_showCircle;
    });
  }

  Future<void> _runFrother() async {
    final response = await http.post(
      Uri.parse('http://172.20.10.6:5000/run_frother'), // 替换为你的本地IP地址
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Output: ${data['output']}');
      print('Error: ${data['error']}');
    } else {
      print('Failed to run frother: ${response.reasonPhrase}');
    }
  }

  void _showConfirmationDialog(
      BuildContext context, String patternTitle, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Are you sure you want to print '$patternTitle'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Choose Frother Pattern',
            style: TextStyle(color: Colors.black), // 设置文字颜色为黑色
          ),
        ),
        backgroundColor: Colors.transparent, // 设置背景颜色为透明
        elevation: 0, // 移除阴影
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 6, // 修改为6个项目
          itemBuilder: (context, index) {
            String patternTitle;
            IconData patternIcon;
            switch (index) {
              case 0:
                patternTitle = 'Circle';
                patternIcon = Icons.circle_outlined;
                break;
              case 1:
                patternTitle = 'Square';
                patternIcon = Icons.crop_square;
                break;
              case 2:
                patternTitle = 'Triangle';
                patternIcon = Icons.change_history;
                break;
              case 3:
                patternTitle = 'Star';
                patternIcon = Icons.star_border_outlined;
                break;
              case 4:
                patternTitle = 'Heart';
                patternIcon = Icons.favorite_border;
                break;
              case 5:
                patternTitle = 'Cloud';
                patternIcon = Icons.cloud_queue;
                break;
              default:
                patternTitle = 'Pattern';
                patternIcon = Icons.help_outline;
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white, // 背景颜色为白色
                borderRadius: BorderRadius.circular(20.0), // 边框圆角
                border: Border.all(color: Colors.black, width: 2), // 黑色加粗边框
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    patternTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Icon(
                    patternIcon,
                    size: 80,
                    color: Colors.grey[700], // 设置图标颜色
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog(context, patternTitle, () {
                        if (index == 0) {
                          _runFrother();
                        } else {
                          _toggleCircle();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD5CEA3), // 按钮颜色
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10), // 按钮变小
                      elevation: 10,
                      shadowColor: Colors.black.withOpacity(0.5),
                    ),
                    child: Text(
                      'Start',
                      style: TextStyle(
                          color: Colors.white, fontSize: 16), // 按钮文字稍微小一点
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: FrotherPage(),
    ));
