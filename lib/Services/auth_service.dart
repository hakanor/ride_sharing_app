import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //giriş yap fonksiyonu
  Future<User?> signIn(String email, String password) async {
    var user = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return user.user;
  }

  //çıkış yap fonksiyonu
  signOut() async {
    return await _auth.signOut();
  }

  //kayıt ol fonksiyonu
  Future<User?> createPerson(String name,String surname,String number, String email, String password) async {
    try{
      var user = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password);

      await _firestore
          .collection("Users")
          .doc(user.user!.uid)
          .set({'name': name,'surname': surname,'number': number, 'email': email,'password':password,"Image":""});

      return user.user;

    } on FirebaseAuthException catch(error){
      String? error_message=error.message;
      Fluttertoast.showToast(msg: "Error : $error_message");
    }

  }

/*
  Future<User?> createPerson(String name, String email, String password) async {

    try{
      var user = await _auth.createUserWithEmailAndPassword(email: email,password: password)
          .then((kullanici){
        FirebaseFirestore.instance.collection("Users").doc(user.user!.uid).set({
          'KullaniciEposta':email,
          'KullaniciSifre':password,
        }).whenComplete(() => print("Kullanıcı Firestore veritabanına eklendi"));
      }).whenComplete(() => print("Kullanıcı Firebase'e kaydedildi."));
    } on FirebaseAuthException catch(error){
      String? error_message=error.message;
      Fluttertoast.showToast(msg: "Error : $error_message");
    }

    var user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password);

    await _firestore
        .collection("Users")
        .doc(user.user!.uid)
        .set({'userName': name, 'email': email,'password':password});

    return user.user;
  }
*/

  String UserIdbul(){
    String id="";
    var currentUser = _auth.currentUser;
    if (currentUser != null) {
      id=currentUser.uid;
    }
    return id;
  }

  Future sifreSifirla(String email) async{
    await _auth.sendPasswordResetEmail(email: email);
  }

  String yazigetir(String userId){
    String userName="";
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get().then((value) {
        userName=value.data()!['userName'];

    });
    return userName;
  }

}