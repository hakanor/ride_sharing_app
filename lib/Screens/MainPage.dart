import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_app/Screens/Chat%20Screens/MainChatPage.dart';
import 'package:ride_sharing_app/Screens/Create%20Listing%20Screens/test_screen.dart';
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
  late Position position;
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future <void> updatePosition() async {
    position = await _determinePosition();
  }

  AuthService _authService = AuthService();
  final List<Widget> _children=[
    HomePage(),
    MyListingsPage(),
    test_screen(current_location_latlng: LatLng(0,0),),
    MainChatPage(),
    ProfilePage(),
  ];
  int _currentIndex=0;

  onTabTapped(int index)async{
    if(index==2){
      await updatePosition();
      LatLng x = new LatLng(position.latitude,position.longitude);
      Navigator.push(context, MaterialPageRoute(builder: (context) => test_screen(current_location_latlng: x,)));
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
            icon: Icon(Icons.assignment),
            label: "İlanlarım",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: "Ekle",
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
