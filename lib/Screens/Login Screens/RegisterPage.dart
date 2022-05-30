import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ride_sharing_app/Screens/Login%20Screens/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late bool _passwordVisible;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordAgainController = TextEditingController();
  String imageurlpp="https://firebasestorage.googleapis.com/v0/b/ride-sharing-app-389d2.appspot.com/o/avatar3.png?alt=media&token=7088e5e8-2fee-4f28-aad7-8bd53a0bacad";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void initState() {
    _passwordVisible = false;
    super.initState();
  }

  Future<User?> createPerson(String name,String surname,String number, String email, String password) async {
    try{
      var user = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password);

      await _firestore
          .collection("Users")
          .doc(user.user!.uid)
          .set({'name': name,'surname': surname,'number': number, 'email': email,'password':password,"Image":imageurlpp,"city":"Şehir seçiniz"});

      return user.user;

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
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 120.0),
                    child: Container(
                      height: size.height * .7,
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
                                  controller: _nameController,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  cursorColor: Colors.white,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                    hintText: 'İsim',
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
                                  controller: _surnameController,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  cursorColor: Colors.white,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                    hintText: 'Soyisim',
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
                                  controller: _numberController,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  cursorColor: Colors.white,
                                  keyboardType: TextInputType.number,
                                  maxLength: 11,
                                  decoration: InputDecoration(
                                    counterText: '',
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                    hintText: 'Tel No',
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
                                    hintText: 'Parola',
                                    prefixText: ' ',
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
                                  controller: _passwordAgainController,
                                  obscureText: !_passwordVisible,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.vpn_key,
                                      color: Colors.white,
                                    ),
                                    hintText: 'Parola Tekrar',
                                    prefixText: ' ',
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
                                height: size.height * 0.04,
                              ),
                              InkWell(
                                onTap: () {
                                  createPerson(
                                      _nameController.text,
                                      _surnameController.text,
                                      _numberController.text,
                                      _emailController.text,
                                      _passwordController.text
                                  )
                                      .then((value) {
                                    return Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()));
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white, width: 2),
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(
                                        child: Text(
                                          "Kaydet",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 20,
                                          ),
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                  EdgeInsets.only(top: size.height * .06, left: size.width * .02),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios_outlined,
                            color: Colors.blue.withOpacity(.75),
                            size: 26,
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.3,
                        ),
                        Text(
                          "Kayıt ol",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.blue.withOpacity(.75),
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}