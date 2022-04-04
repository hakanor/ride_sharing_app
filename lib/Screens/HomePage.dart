import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// BU SAYFA İLANLARIN GENEL OLARAK LİSTELENDİĞİ SAYFA OLACAKTIR.

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final TextEditingController controller = TextEditingController();
  Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('Listings').snapshots();

  void search(String text){
      setState(() {
        _usersStream = FirebaseFirestore.instance.collection('Listings').where("start_location",isEqualTo: text).snapshots();
      });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body:SizedBox(
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
                            "Tüm İlanlar",
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

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: controller,
                  onTap: (){
                      search(controller.text);
                      },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Arama yapın",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.transparent),
                    )
                  ),
                ),
              ),

              ElevatedButton(onPressed: (){setState(() {
                _usersStream = FirebaseFirestore.instance.collection('Listings').snapshots();
              });}, child: Icon(Icons.clear)),

              Flexible(
                child: StreamBuilder<QuerySnapshot>(
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
                            print(data['user_id']);
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}
