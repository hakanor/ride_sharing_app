import 'package:ride_sharing_app/Screens/Login%20Screens/PasswordResetPage.dart';
import 'package:ride_sharing_app/Services/auth_service.dart';
import 'package:ride_sharing_app/Screens/Login%20Screens/RegisterPage.dart';
import 'package:flutter/material.dart';
import '../MyHomePage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late bool _passwordVisible;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void initState() {
    _passwordVisible = false;
    super.initState();
  }

  AuthService _authService = AuthService();

  Future <void> girisyap() async {
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text)
          .then((kullanici) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=> MyHomePage(title: 'Araç Paylaşım',)),(Route<dynamic>route)=>false);
      }).whenComplete(() => print("Giriş Yapıldı"));
    } on FirebaseAuthException catch(error){
      String? error_message=error.message;
      Fluttertoast.showToast(msg: "Error : $error_message");
    }
  }

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
                                obscureText: !_passwordVisible,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.vpn_key,
                                    color: Colors.white,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility : Icons.visibility_off,color: Theme.of(context).primaryColorDark,
                                    ),
                                    onPressed: (){
                                      setState(() {
                                        _passwordVisible=!_passwordVisible;
                                      });
                                    },
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
                              height: size.height * 0.04,
                            ),


                            InkWell(
                              onTap: () {
                                girisyap();

                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 1),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(30))),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Center(
                                      child: Text(
                                        "Giriş yap",
                                        style: TextStyle(
                                          color: Colors.blue,
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
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 1),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(30))),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Center(
                                      child: Text(
                                        "Kayıt Ol",
                                        style: TextStyle(
                                          color: Colors.blue,
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
                                        builder: (context) => ForgotPassword()));
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5),

                                child: Text("Şifremi unuttum?",style: TextStyle(color: Colors.white),),
                              ),
                            ),



                            // TEST İŞLEMLERİ İÇİN HIZLI GİRİŞ BUTONU
                            SizedBox(
                              height: size.height *0.02,
                            ),
                            InkWell(
                              onTap: () {
                                _emailController.text="hakanor1@gmail.com";
                                _passwordController.text="123Hakan";
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5),

                                child: Text("TEST",style: TextStyle(color: Colors.white),),
                              ),
                            ),
                            // TEST İŞLEMLERİ İÇİN HIZLI GİRİŞ BUTONU


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