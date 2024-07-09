import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  int _selectedIndex = -1;
  final List<String> categories = [
    'Espresso',
    'Espresso Macchiato',
    'Coffee',
    'Cappuccino',
    'Late Macchiato'
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedCategory();
  }

  _loadSelectedCategory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedCategory = prefs.getString('selectedCategory');
    if (selectedCategory != null) {
      setState(() {
        _selectedIndex = categories.indexOf(selectedCategory);
      });
    }
  }

  _saveSelectedCategory() async {
    if (_selectedIndex != -1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedCategory', categories[_selectedIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Categories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildListTile(0, Icons.local_cafe, 'Espresso'),
            Divider(),
            _buildListTile(1, Icons.local_cafe, 'Espresso Macchiato'),
            Divider(),
            _buildListTile(2, Icons.local_cafe, 'Coffee'),
            Divider(),
            _buildListTile(3, Icons.local_cafe, 'Cappuccino'),
            Divider(),
            _buildListTile(4, Icons.local_cafe, 'Late Macchiato'),
            Spacer(),
            Center(
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFFD5CEA3), // 设置按钮颜色
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _saveSelectedCategory();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Confirm',
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

  Widget _buildListTile(int index, IconData icon, String title) {
    return ListTile(
      leading: Icon(
        icon,
        color: _selectedIndex == index
            ? Color.fromARGB(255, 120, 84, 65)
            : Colors.black,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _selectedIndex == index
              ? Color.fromARGB(255, 120, 84, 65)
              : Colors.black,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}
