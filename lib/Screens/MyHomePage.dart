import 'package:ride_sharing_app/Screens/PersonalAdsPage.dart';
import 'package:flutter/material.dart';
import '../Services/auth_service.dart';
import 'HomePage.dart';
import 'Login Screens/LoginPage.dart';
import 'ProfilePage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  AuthService _authService = AuthService();
  final List<Widget> _children=[
    HomePage(),
    PersonalAdsPage(),
    ProfilePage(), //
  ];
  int _currentIndex=0;

  onTabTapped(int index){
    setState(() {
      _currentIndex=index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Araç Paylaşım Uygulaması"),
        actions: [
          IconButton(
            onPressed: (){
              _authService.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => LoginPage()));
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),

      body:_children[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap:onTabTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: "Tüm İlanlar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "İlanlarım",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Profilim",
          ),

        ],
      ),
    );
  }
}
