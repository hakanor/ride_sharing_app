import 'package:cloud_firestore/cloud_firestore.dart';
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
  late Future<String> _dataFuture;
  late Future<String> _dataFuture2;

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


  Future<String> getImageUrl(String uid)async {
    String b="";
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .get().then((value) {
      b=value.data()!['Image'];
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
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Center(
          child: Column(
            children: [
              Padding(
                padding:
                EdgeInsets.only(top: size.height * .05),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: ((size.width)-40)/3,
                      ),
                      Container(
                        child: Center(
                          child: Text(
                            "Mesaj Kutusu",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.blue.withOpacity(.75),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Container(
                        width: ((size.width)-40)/3,
                      ),

                    ],
                  ),
                ),
              ),

              Flexible(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                  FirebaseFirestore.instance
                      .collection('Conversations')
                      .where('members',arrayContains: userId)
                      .snapshots(),

                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if(snapshot.hasData && snapshot.data?.size==0){
                      return Center(
                        child: Text(
                          "Mesaj Kutunuzda Hiç Mesaj Yok",style: TextStyle(fontSize: 22),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Yükleniyor...");
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top:5.0),
                      child: ListView(
                        children: snapshot.data!.docs.map((DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                          String name_surname=data['name_surname'];
                          String name_surname2=data['name_surname2'];
                          String displayMessage = data['displayMessage'];
                          List members=data["members"]; //kullanılmayan
                          String urlsend="";
                          if(members[0]==userId){
                            urlsend=members[1];
                          }
                          else{
                            urlsend=members[0];
                          }

                          if(displayMessage.length>30){
                            displayMessage=displayMessage.substring(0,30)+"...";
                          }

                          return Column(
                            children: [
                              ListTile(
                                tileColor: Colors.white,
                                leading: FutureBuilder<String>(
                                  future: getImageUrl(urlsend), // async work
                                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting: return CircularProgressIndicator();
                                      default:
                                        if (snapshot.hasError)
                                          return Text('Error: ${snapshot.error}');
                                        else{
                                          String? url=snapshot.data;
                                          return CircleAvatar(
                                              backgroundImage:
                                              NetworkImage(url!),
                                          );
                                        }
                                    }
                                  },
                                ),

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
                                            return Text(name_surname);
                                        }
                                    }
                                  },
                                ),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left:4.0,bottom: 3,top: 3),
                                      child: Text(data['start_location']+" - "+data['end_location'],style: TextStyle(fontSize: 12),),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Text(data['displayMessage']==null ?"" :displayMessage,),
                                    ),
                                  ],
                                ),

                                trailing: Padding(
                                  padding: const EdgeInsets.only(top:1,right: 1,),
                                  child: Column(
                                    children: [
                                      Text(data['time_formatted']==null ?"" : data['time_formatted']),
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
                                ),
                                onTap: (){
                                  String uid1=data['members'][0];
                                  String uid2=data['members'][1];
                                  if(uid1==userId){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationPage(
                                      userId: uid2,
                                      conversationId: document.id,
                                    )));
                                  }
                                  else{
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationPage(
                                      userId: uid1,
                                      conversationId: document.id,
                                    )));
                                  }
                                },
                              ),
                              SizedBox(
                                height: 5,
                              )
                            ],
                          );
                        }).toList(),
                      ),
                    );

                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
