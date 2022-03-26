import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


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


  @override
  Widget build(BuildContext context) {

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
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height* 0.04),
                  Center(
                    //TODO Display user profile image
                    child: Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.18,
                          width: MediaQuery.of(context).size.height* 0.18,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue,width: 4),
                            borderRadius: BorderRadius.circular(30),
                          ),

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
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
                              // ON TAP CAMERA BUTTON
                              print("test");
                            },
                            child: Container(
                              width:30,
                              height: 30,
                              child: Icon(Icons.camera_alt_outlined),
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
                      icon: Icons.create_outlined, onPress: (){},
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                  Container(
                    child: buildShowUserNameAndEmail(
                      desc: "Email",
                      text: streamSnapshot.data!['email'],
                      icon: Icons.create_outlined, onPress: (){},
                    ),
                  ),
                  SizedBox(height:MediaQuery.of(context).size.height* 0.03),

                  Container(
                    child: buildShowUserNameAndEmail(
                      desc: "Telefon Numarası",
                      text: streamSnapshot.data!['number'],
                      icon: Icons.create_outlined, onPress: (){},
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                ],
              ),
            );
          },
        ),
      ),
    );
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
              onTap: (){},
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
