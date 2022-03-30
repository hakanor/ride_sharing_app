import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Login Screens/LoginPage.dart';

class PasswordChangePage extends StatefulWidget {
  const PasswordChangePage({Key? key}) : super(key: key);

  @override
  _PasswordChangePageState createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {

  @override
  void initState() {
    // TODO: implement initState
    getPassword();
    super.initState();
  }

  final TextEditingController oldPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  var oldPassword="";
  var newPassword="";
  final currentUser=FirebaseAuth.instance.currentUser;

  void dispose(){
    newPassController.dispose();
    oldPassController.dispose();
    super.dispose();
  }

  void getPassword()async{

    try{
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser?.uid)
          .get().then((value) {
        setState(() {
          oldPassword=value.data()!['password'];
        });
      });
      print(oldPassword);

    } on FirebaseAuthException catch(error){
      String? error_message=error.message;
      Fluttertoast.showToast(msg: "Error : $error_message");
    }
  }


  void changePassword(String password)async{
    try{
      await currentUser!.updatePassword(password);

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser?.uid)
          .update({'password':password});
      FirebaseAuth.instance.signOut();

    } on FirebaseAuthException catch(error){
      String? error_message=error.message;
      Fluttertoast.showToast(msg: "Error : $error_message");
    }
  }

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
              EdgeInsets.only(top: size.height * .06,left: size.width*.045),
              child: Align(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    Container(
                      width: ((size.width)-40)/3,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: () {Navigator.pop(context);},
                          icon: Icon(
                            Icons.arrow_back_ios_outlined,
                            color: Colors.blue.withOpacity(.75),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Center(
                        child: Text(
                          "Şifremi değiştir",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.blue.withOpacity(.75),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),

            Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _key,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        SizedBox(height: MediaQuery.of(context).size.height * 0.08),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  "Eski şifre:",
                                  style: TextStyle(color: Colors.white70,fontWeight: FontWeight.w400,fontSize: 14),),
                              ),
                              TextFormField(
                                keyboardType: TextInputType.text,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                    hintText: "Eski şifrenizi girin",
                                  hintStyle: TextStyle(color: Colors.black45),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Alan boş bırakılamaz.';
                                  return null;
                                },
                                controller: oldPassController,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  "Yeni şifre:",
                                  style: TextStyle(color: Colors.white70,fontWeight: FontWeight.w400,fontSize: 14),),
                              ),
                              TextFormField(
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                    hintText: "Yeni şifrenizi girin",
                                  hintStyle: TextStyle(color: Colors.black45),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Alan boş bırakılamaz.';
                                  return null;
                                },
                                controller: newPassController,
                              ),

                            ],
                          ),
                        ),

                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                        ElevatedButton(onPressed: (){
                          if (_key.currentState!.validate()) {
                            _key.currentState!.save();
                            setState(() {
                              newPassword=newPassController.text;
                            });

                            getPassword();
                            if(oldPassword==oldPassController.text){
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                                  LoginPage()), (Route<dynamic> route) => false);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("Şifreniz değiştirildi, lütfen tekrar giriş yapın.")));
                              changePassword(newPassController.text);
                              oldPassController.clear();
                            }
                            else{
                              Fluttertoast.showToast(msg: "Eski şifreniz yanlış.");
                            }

                          }

                        }, child: Text("Kaydet")),

                      ],
                    ),
                  ),
                )
            ),
          ],
        )
      ),
    );
  }
}
