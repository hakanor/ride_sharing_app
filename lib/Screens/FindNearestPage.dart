import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// BU SAYFA İLANLARIN GENEL OLARAK LİSTELENDİĞİ SAYFA OLACAKTIR.

class FindNearestPage extends StatefulWidget {

  LatLng place_latlng;
  FindNearestPage({required this.place_latlng});

  @override
  _FindNearestPageState createState() => _FindNearestPageState();
}

class _FindNearestPageState extends State<FindNearestPage> {

  TextEditingController controller = TextEditingController();
  Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.
  collection('Listings').snapshots();

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }


  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }


  Future<String> getPhoneNumber (String userid) async {
    String number="";
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userid)
        .get().then((value) {
      number=value.data()!['number'];
      print(number);
    });
    return number;
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
                              "Yakın İlanlar",
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
                          String start_location=data['start_location'];
                          String end_location=data['end_location'];
                          String date=data['date'];
                          String time=data['time'];
                          String price=data['price'];
                          String name_surname=data['name_surname'];
                          String userId=data['user_id'];

                          String coord=data['coord'];
                          var splitted=coord.split('/');
                          for(int i=0; i<splitted.length-1; i++){
                            String x = splitted[i];
                            var splitted2=x.split('-');
                            double sonuc=calculateDistance(widget.place_latlng.latitude, widget.place_latlng.longitude, double.parse(splitted2[0]), double.parse(splitted2[1]));
                            print(sonuc);
                            if(sonuc<1){
                              print("Bulundu");
                              return GestureDetector(
                                onTap: (){
                                  //TIKLANILDIĞI ZAMAN İLAN DETAY SAYFASINA GİTMESİ İÇİN GESTURE
                                  Fluttertoast.showToast(msg: document.id);
                                },
                                child: buildTripCard(
                                  context,
                                  start_location: start_location,
                                  end_location: end_location,
                                  date: date,
                                  time: time,
                                  price: price,
                                  name_surname: name_surname,
                                  userId: userId,
                                ),
                              );
                            }
                          }

                          return Container();
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
        required String userId,

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
                      String phoneNumber= await getPhoneNumber(userId);
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
