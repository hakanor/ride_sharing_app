import 'package:ride_sharing_app/Screens/Chat%20Screens/MainChatPage.dart';
import 'package:ride_sharing_app/Screens/Listing%20Screens/test_screen.dart';
import 'package:ride_sharing_app/Screens/MyListingsPage.dart';
import 'package:flutter/material.dart';
import '../Services/auth_service.dart';
import 'HomePage.dart';
import 'Profile Screens/ProfilePage.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  AuthService _authService = AuthService();
  final List<Widget> _children=[
    HomePage(),
    test_screen(),
    MyListingsPage(),
    MainChatPage(),
    ProfilePage(),
  ];
  int _currentIndex=0;

  onTabTapped(int index){
    if(index==1){
      Navigator.push(context, MaterialPageRoute(builder: (context) => test_screen()));
    }
    else{
    setState(() {
      _currentIndex=index;
    });}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:SafeArea(
        child: _children[_currentIndex],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type:  BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap:onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: "Tüm İlanlar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_outlined),
            label: "Ekle",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "İlanlarım",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Mesajlar",
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
