import 'package:flutter/material.dart';
import '../Services/auth_service.dart';
import 'Listing Screens/test_screen.dart';
import 'Login Screens/LoginPage.dart';

class PersonalAdsPage extends StatefulWidget {
  const PersonalAdsPage({Key? key}) : super(key: key);

  @override
  _PersonalAdsState createState() => _PersonalAdsState();
}

class _PersonalAdsState extends State<PersonalAdsPage> {

  AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
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

      ),
    );
  }
}
