import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:ride_sharing_app/Screens/Profile%20Screens/PasswordChangePage.dart';
import 'dart:io';

import '../Login Screens/LoginPage.dart';

enum _MenuValues {
  settings,
  logout,
}

class ProfilePage extends StatefulWidget {

  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState  extends State<ProfilePage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('Users');
  String? userid= FirebaseAuth.instance.currentUser?.uid;
  String imageUrl='';

@override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: usersCollection.doc(user?.uid).snapshots(),
          builder: (ctx, streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            }

            return SingleChildScrollView(
              child: Stack(
                children: [
                  Padding(
                    padding:
                    EdgeInsets.only(top: size.height * .03),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          Container(
                            width: ((size.width)-40)/3,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                              ),
                            ),
                          ),
                          Container(
                            width: ((size.width)-40)/3,
                            child: Center(
                              child: Text(
                                "Profilim",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.blue.withOpacity(.75),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Container(
                            width: ((size.width)-40)/3,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: PopupMenuButton<_MenuValues>(
                                icon: Icon(Icons.settings_outlined,color: Colors.blue,),
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem(
                                    child: Text('Şifremi değiştir'),
                                    value: _MenuValues.settings,
                                  ),
                                  PopupMenuItem(
                                    child: Text("Çıkış Yap"),
                                    value: _MenuValues.logout,
                                  ),
                                ],
                                onSelected: (value) {
                                  switch (value) {
                                    case _MenuValues.settings:
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => PasswordChangePage()));
                                      break;
                                    case _MenuValues.logout:
                                      FirebaseAuth.instance.signOut();
                                      Navigator.pushReplacement(context, MaterialPageRoute(
                                          builder: (context) => LoginPage()));
                                      break;
                                  }
                                },
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),


                  Center(
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height* 0.12),
                        Center(
                          //TODO Display user profile image
                            child: Stack(
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.18,
                                  width: MediaQuery.of(context).size.height* 0.18,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blue,width: 4),
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(.55),
                                          blurRadius: 10,
                                          spreadRadius: 2)
                                    ],
                                  ),

                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: streamSnapshot.data!['Image'] != 'Image goes here' ? Image.network(
                                      streamSnapshot.data!['Image'],
                                      fit: BoxFit.cover,
                                    )
                                        : Center(
                                      child:Image.asset('assets/play_store_512.png'),
                                    ),
                                  ),
                                ),

                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: (){
                                      selectPhoto();
                                    },
                                    child: Container(
                                      width:30,
                                      height: 30,
                                      child: Icon(Icons.camera_alt_rounded,color: Colors.white,size: 20 ,),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ),
                        SizedBox(height:MediaQuery.of(context).size.height* 0.03),

                        Container(
                          child: buildShowUserNameAndEmail(
                            desc: "İsim Soyisim",
                            text: streamSnapshot.data!['name']+" "+streamSnapshot.data!['surname'],
                            icon: Icons.create_outlined, onPress: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NameChangePage(userid2: userid,)));
                          },
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                        Container(
                          child: buildShowUserNameAndEmail(
                            desc: "Telefon Numarası",
                            text: streamSnapshot.data!['number'],
                            icon: Icons.create_outlined, onPress: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NumberChangePage(userid2: userid,)));
                          },
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                        Container(
                          child: buildShowUserNameAndEmailWithoutIcon(
                            desc: "Email",
                            text: streamSnapshot.data!['email'],
                          ),
                        ),
                        SizedBox(height:MediaQuery.of(context).size.height* 0.03),
                      ],
                    ),
                  ),
                ],
              )
            );
          },
        ),
      ),
    );
  }

  // PROFILE PICTURE PICK / CROP / COMPRESS / UPLOAD & CHANGE FUNCTIONS //
  final ImagePicker _picker=ImagePicker();

  Future selectPhoto() async{
    await showModalBottomSheet(context: context, builder: (context)=> BottomSheet(
      builder: (context)=>  Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: Icon(Icons.camera),title: Text("Kamera"), onTap:(){
            Navigator.of(context).pop();
            pickImage(ImageSource.camera);
          }),
          ListTile(leading: Icon(Icons.photo),title: Text("Galeriden Seç"), onTap:(){
            Navigator.of(context).pop();
            pickImage(ImageSource.gallery);
          }),
        ],
      ),
      onClosing: (){},

    ));
  }

  Future pickImage(ImageSource source) async{
    final pickedFile = await _picker.pickImage(source: source,imageQuality: 50);
    if(pickedFile==null){
      return;
    }
    var file = await ImageCropper().cropImage(sourcePath: pickedFile.path,aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1));
    if(file==null){
      return;
    }
    file = await compressImage(file.path,35);

    await uploadFile(file.path);

  }
  Future <File> compressImage(String path,int quality) async {
    final newPath = p.join((await getTemporaryDirectory()).path,'${DateTime.now()}.${p.extension(path)}');

    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      newPath,
      quality: quality,
    );
    return result!;
  }

  Future uploadFile(String path) async{
    final ref = storage.FirebaseStorage.instance.ref()
        .child('images')
        .child('$userid');

    final result = await ref.putFile(File(path));
    final fileUrl= await result.ref.getDownloadURL();

    setState(() {
      imageUrl=fileUrl;
      print(imageUrl);
    });
    changePhoto(imageUrl);
  }

  Future changePhoto(String imageUrl) async{
    setState(() {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userid)
          .update({'Image':imageUrl,});
    });
  }

}

Widget buildShowUserNameAndEmail(
    {required String desc,required String text, required Function onPress, required IconData icon}) {
  return Container(
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
            desc,
            style: TextStyle(color: Colors.white70,fontWeight: FontWeight.w400,fontSize: 14),),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15),
            ),

            InkWell(
              onTap: (){onPress();},
              child: Icon(
                icon,
                size: 18,
              ),
            ),
            // IconButton(onPressed: onPress, )
          ],
        ),
      ],
    ),
  );
}

Widget buildShowUserNameAndEmailWithoutIcon(
    {required String desc,required String text,}) {
  return Container(
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
            desc,
            style: TextStyle(color: Colors.white70,fontWeight: FontWeight.w400,fontSize: 14),),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15),
            ),

          ],
        ),
      ],
    ),
  );
}

class NameChangePage extends StatelessWidget {
  NameChangePage({Key? key,this.userid2}) : super(key: key);
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final userid2;
  final TextEditingController textEditingControllername = TextEditingController();
  final TextEditingController textEditingControllersurname = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String? userid = userid2;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title:Text("İsim Soyisim Değiştirme"),),
      body: SingleChildScrollView(
        child: Center(
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
                            "Yeni isim:",
                            style: TextStyle(color: Colors.white70,fontWeight: FontWeight.w400,fontSize: 14),),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Yeni isim giriniz."
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Alan boş bırakılamaz.';
                            return null;
                          },
                          controller: textEditingControllername,
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
                            "Yeni soyisim:",
                            style: TextStyle(color: Colors.white70,fontWeight: FontWeight.w400,fontSize: 14),),
                        ),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "Yeni soyisim giriniz."
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Alan boş bırakılamaz.';
                            return null;
                          },
                          controller: textEditingControllersurname,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                  ElevatedButton(onPressed: (){
                    if (_key.currentState!.validate()) {
                      _key.currentState!.save();
                      try{
                        FirebaseFirestore.instance
                            .collection('Users')
                            .doc(userid)
                            .update({'name':textEditingControllername.text,'surname':textEditingControllersurname.text,}).whenComplete((){
                          Fluttertoast.showToast(msg: "Güncelleme Başarılı");
                          Navigator.pop(context);
                        });
                      }on FirebaseAuthException catch(error){
                        String? error_message=error.message;
                        Fluttertoast.showToast(msg: "Error : $error_message");
                      }
                    }

                  }, child: Text("Kaydet")),

                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}

class NumberChangePage extends StatelessWidget {
  NumberChangePage({Key? key, this.userid2}) : super(key: key);
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final String? userid2;
  final TextEditingController textEditingControllernumber = TextEditingController();
  @override
  Widget build(BuildContext context) {
    String? userid = userid2;


    return Scaffold(
      appBar: AppBar(title:Text("Numara Değiştirme"),),
      body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

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
                            "Yeni numara:",
                            style: TextStyle(color: Colors.white70,fontWeight: FontWeight.w400,fontSize: 14),),
                        ),
                        TextFormField(
                          maxLength: 11,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "05338889944 şeklinde",
                          ),
                          controller: textEditingControllernumber,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Alan boş bırakılamaz.';
                            else if (value.length != 11) return 'Numara 11 haneli olmalıdır.';
                            else return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                  ElevatedButton(onPressed: (){
                    if(_key.currentState!.validate()){
                      _key.currentState!.save();

                      try{
                        FirebaseFirestore.instance
                            .collection('Users')
                            .doc(userid)
                            .update({'number':textEditingControllernumber.text,}).whenComplete((){
                          Fluttertoast.showToast(msg: "Güncelleme Başarılı");
                          Navigator.pop(context);}
                        );
                      }on FirebaseAuthException catch(error){
                        String? error_message=error.message;
                        Fluttertoast.showToast(msg: "Error : $error_message");
                      }
                    }

                  }, child: Text("Kaydet")),

                ],
              ),
            ),
          )
      ),
    );
  }
}