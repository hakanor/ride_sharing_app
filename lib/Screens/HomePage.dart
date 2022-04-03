import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// BU SAYFA İLANLARIN GENEL OLARAK LİSTELENDİĞİ SAYFA OLACAKTIR.

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('Listings').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("tüm ilanlar"),),
      body:StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Yükleniyor");
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              String str1= data['start_location']+" ->  "+data['end_location'];
              String str2= "Saat : "+ data['time']+" Tarih: "+data['date'];
              return ListTile(
                title: Text(str1),
                subtitle: Text(str2),
                onTap: (){
                  print(str1);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
