import 'package:flutter/material.dart';
import 'package:ride_sharing_app/Screens/test_screen.dart';
import 'package:ride_sharing_app/Services/auth_service.dart';
import 'Login Screens/LoginPage.dart';

// BU SAYFA İLANLARIN GENEL OLARAK LİSTELENDİĞİ SAYFA OLACAKTIR.

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {

    String userId= _authService.UserIdbul();

    return Container(
      child: (
      Column(
        children: [
          Text("User id : $userId"),
          ElevatedButton(
            child: Text("userid bul"),
            onPressed: (){
                setState(() {
                  _authService.UserIdbul();
                });
              },
          ),
          ElevatedButton(
            child: Text("İlan ver"),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => test_screen()));
            },
          ),
          ElevatedButton(
            child: Text("Çıkış yap"),
            onPressed: (){
              _authService.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => LoginPage()));
            },
          ),
        ],
      )

      ),
    );
  }
}
