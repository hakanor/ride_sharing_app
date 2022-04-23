import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

// BU SAYFA İLANLARIN GENEL OLARAK LİSTELENDİĞİ SAYFA OLACAKTIR.

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final TextEditingController controller = TextEditingController();
  Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.
  collection('Listings').
  orderBy("date",descending: true).
  orderBy("time").snapshots();

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }


  Future<String> getPhoneNumber () async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    String number="";
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(_auth.currentUser?.uid)
        .get().then((value) {
      number=value.data()!['number'];
      print(number);
    });
    return number;
  }

  void search(String text){
      setState(() {
        _usersStream = FirebaseFirestore.instance.
        collection('Listings').
        where("start_location",isEqualTo: text).
        snapshots();
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
                controller.text="";
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
                        //String str1= data['start_location']+" ->  "+data['end_location'];
                        //String str2= "Saat : "+ data['time']+" Tarih: "+data['date'];
                        String start_location=data['start_location'];
                        String end_location=data['end_location'];
                        String date=data['date'];
                        String time=data['time'];
                        String price=data['price'];
                        String name_surname=data['name_surname'];



                        return GestureDetector(
                          onTap: (){
                            //TIKLANILDIĞI ZAMAN İLAN DETAY SAYFASINA GİTMESİ İÇİN GESTURE
                            print(data['user_id']);
                            },
                          child: buildTripCard(
                              context,
                              start_location: start_location,
                              end_location: end_location,
                              date: date,
                              time: time,
                              price: price,
                              name_surname: name_surname,
                          ),
                        );
                        /*return ListTile(
                          title: Text(str1),
                          subtitle: Text(str2),
                          onTap: (){
                            print(str1);
                            print(data['user_id']);
                          },
                        );*/
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

  Widget buildTripCard(
      BuildContext context,
      {
        required String start_location,
        required String end_location,
        required String date,
        required String time,
        required String price,
        required String name_surname,

      } ) {

    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[

              // KALKIŞ NOKTASI
              Padding(
                padding: const EdgeInsets.only(top: 8.0,bottom: 6),
                child: Row(children: <Widget>[
                  Icon(Icons.radio_button_checked,color: Colors.blue,),
                  Padding(
                    padding: const EdgeInsets.only(left:4.0),
                    child: Text(start_location, style: new TextStyle(fontSize: 17.0),),
                  ),
                  //Spacer(),
                ]),
              ),

              // DOTTED LİNE
              Padding(
                padding: const EdgeInsets.only(left:10),
                child:Row(children: [
                  Container(
                    height: 30,
                    child: const DottedLine(
                      direction: Axis.vertical,
                      lineLength: double.infinity,
                      lineThickness: 2.0,
                      dashLength: 4.0,
                      dashColor: Colors.black87,
                    ),
                  ),
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color: Colors.grey.withAlpha(80),
                          height: 0.5,
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 20,
                          ),
                        ),
                      ))
                ]),
              ),

              // VARIŞ NOKTASI
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(children: <Widget>[
                  const Icon(Icons.location_on,color: Colors.red,),
                  Padding(
                    padding: const EdgeInsets.only(left:4.0),
                    child: Text(end_location, style: new TextStyle(fontSize: 17.0),),
                  ),
                  //Spacer(),
                ]),
              ),

              // SAAT - TARİH
              Padding(
                padding: const EdgeInsets.only(left:4,top: 4.0, bottom: 4.0),
                child: Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 4,top: 4),
                    child: Align(alignment:Alignment.topLeft,child: Text("Saat  : $time",style: TextStyle(fontSize: 15),)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4,top: 4),
                    child: Align(alignment: Alignment.topLeft,child: Text("Tarih : $date",style: TextStyle(fontSize: 15),)),
                  ),
                ]),
              ),

              Padding(
                padding: const EdgeInsets.only(left:4,top: 8.0, bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Image(image: AssetImage('assets/play_store_513.png'),),
                      height: 20,
                      width: 20,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text("$price TL ", style: new TextStyle(fontSize: 22.0),)),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(name_surname),
                    ),
                    GestureDetector(child: Icon(Icons.phone),onTap: ()async{
                      String phoneNumber= await getPhoneNumber();
                      _makePhoneCall(phoneNumber);
                    },),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}
