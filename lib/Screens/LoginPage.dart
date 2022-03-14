import 'package:ride_sharing_app/Services/auth_service.dart';
import 'package:ride_sharing_app/Screens/RegisterPage.dart';
import 'package:flutter/material.dart';
import 'MyHomePage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,

        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
               Padding(
                padding: EdgeInsets.only(top: 80,bottom:20 ,right: 20,left: 20),
                child: SizedBox(
                  height: 90,
                  width: 90,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(.75),
                      borderRadius: BorderRadius.all(Radius.circular(60)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(.75),
                              blurRadius: 10,
                              spreadRadius: 2)
                        ]
                    ),
                    child: Image(image: AssetImage('assets/play_store_512.png'),
                    ),
                  ),
                ),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    height: size.height * .5,
                    width: size.width * .85,
                    decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(.75),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(.75),
                              blurRadius: 10,
                              spreadRadius: 2)
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextField(
                                controller: _emailController,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                cursorColor: Colors.white,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.mail,
                                    color: Colors.white,
                                  ),
                                  hintText: 'E-Mail',
                                  prefixText: ' ',
                                  hintStyle: TextStyle(color: Colors.white),
                                  focusColor: Colors.white,
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      )),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      )),
                                )),
                            SizedBox(
                              height: size.height * 0.02,
                            ),
                            TextField(
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                cursorColor: Colors.white,
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.vpn_key,
                                    color: Colors.white,
                                  ),
                                  hintText: 'Parola',
                                  prefixText: ' ',
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  focusColor: Colors.white,
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      )),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      )),
                                )),
                            SizedBox(
                              height: size.height * 0.08,
                            ),
                            InkWell(
                              onTap: () {
                                _authService
                                    .signIn(
                                    _emailController.text, _passwordController.text)
                                    .then((value) {
                                  return Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyHomePage(title: "Araç Paylaşım Uygulaması")));
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 2),
                                    //color: colorPrimaryShade,
                                    borderRadius: BorderRadius.all(Radius.circular(30))),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Center(
                                      child: Text(
                                        "Giriş yap",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      )),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.02,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RegisterPage()));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    height: 1,
                                    width: 75,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Kayıt ol",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Container(
                                    height: 1,
                                    width: 75,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}