// import 'package:flutter/material.dart';
// import 'device/my_device.dart';
// import 'frother.dart';
// import 'sprinkle.dart';
// import 'my_account.dart';

// class MainPage extends StatefulWidget {
//   @override
//   _MainPageState createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   int _selectedIndex = 0;
//   final List<Widget> _widgetOptions = [
//     MyDevicePage(),
//     FrotherPage(),
//     SprinklePage(),
//     MyAccountPage(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // 移除 AppBar
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _widgetOptions,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.devices),
//             label: 'My Device',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.local_drink),
//             label: 'Frothering',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.spa),
//             label: 'Sprinkling',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.account_circle),
//             label: 'My Account',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Color(0xFF3C2A21),
//         unselectedItemColor: Colors.grey,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:my_first_app/device_list.dart';
import 'device/my_device.dart';
import 'device/my_device_test.dart';
import 'frother.dart';
import 'sprinkle.dart';
import 'my_account.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [

    //MyDevicePage(),
    DeviceList(),
    FrotherPage(),
    SprinklePage(),
    MyAccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(child: child, opacity: animation);
        },
        child: IndexedStack(
          key: ValueKey<int>(_selectedIndex),
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'My Device',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_drink),
            label: 'Frothering',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.spa),
            label: 'Sprinkling',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'My Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF3C2A21),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MainPage(),
  ));
}
