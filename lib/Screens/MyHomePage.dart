import 'package:ride_sharing_app/Screens/test_screen.dart';
import 'package:flutter/material.dart';
import '../Services/auth_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ana Sayfa"),
        actions: [
          IconButton(
            onPressed: (){
              _authService.signOut();
              Navigator.pop(context);
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Container(
        color: Colors.white30,
        child:Center(
          child: ElevatedButton(
            child: Text("İlan Ekle"),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => test_screen()));
            },
          ),
        ),
      ),
    );
  }
}
