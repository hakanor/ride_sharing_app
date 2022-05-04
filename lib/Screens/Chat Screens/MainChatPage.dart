import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ride_sharing_app/Screens/Chat%20Screens/ConversationPage.dart';
import 'package:ride_sharing_app/Services/auth_service.dart';

class MainChatPage extends StatefulWidget {
  const MainChatPage({Key? key}) : super(key: key);

  @override
  _MainChatPageState createState() => _MainChatPageState();
}

class _MainChatPageState extends State<MainChatPage> {
  AuthService _auth=AuthService();

  String url="";
  String url2="https://firebasestorage.googleapis.com/v0/b/ride-sharing-app-389d2.appspot.com/o/avatar3.png?alt=media&token=7088e5e8-2fee-4f28-aad7-8bd53a0bacad";

  String userId="";
  String name_surname_current="";
  late Future<String> _dataFuture;

  Future<String> getNameSurname(String uid)async {
    String b="";
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .get().then((value) {
      b=value.data()!['name']+" "+value.data()!['surname'];
    });
    return b;
  }

  @override
  void initState() {
    userId=_auth.UserIdbul();
    _dataFuture=getNameSurname(userId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream:
      FirebaseFirestore.instance
          .collection('Conversations')
          .where('members',arrayContains: userId)
          .snapshots(),

      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Yükleniyor...");
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            //TODO name_surname'ye gelen id ile isim soyisim çek setstate initstate ile ayarla
            String name_surname=data['name_surname'];
            String name_surname2=data['name_surname2'];

            return ListTile(
              tileColor: Colors.white,
              leading: CircleAvatar(
                backgroundImage:
                NetworkImage(url==""?url2 : url),),

              title: FutureBuilder<String>(
                future: _dataFuture, // async work
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting: return Text('Yükleniyor');
                    default:
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');
                      else{
                        String? name=snapshot.data;
                        if(name==name_surname){
                          return Text(name_surname2);
                        }
                        else
                          return Text('Result: ${snapshot.data}');
                      }
                  }
                },
              ),
              subtitle: Text(data['displayMessage']==null ?"" :data['displayMessage'],),
              trailing: Column(
                children: [
                  Text(data['time']==null ?"" : data['time']), //TODO timestamps
                  Container(
                    child: Center(
                      child: Text("16",style: TextStyle(fontSize: 11,color: Colors.white,fontWeight: FontWeight.bold),),
                    ), //TODO notification
                    width: 20,
                    height: 20,
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  )
                ],
              ),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationPage(
                  userId: userId,
                  conversationId: document.id,
                )));
              },
            );
          }).toList(),
        );

      },
    );
  }
}
