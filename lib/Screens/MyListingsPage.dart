import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_app/Screens/EditListingPage.dart';

import 'DetailedListingPage.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({Key? key}) : super(key: key);

  @override
  _PersonalAdsState createState() => _PersonalAdsState();
}

class _PersonalAdsState extends State<MyListingsPage> {

  Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.
  collection('Listings').
  where("user_id",isEqualTo: FirebaseAuth.instance.currentUser?.uid).
  orderBy("date",descending: true).
  orderBy("time").snapshots();

  List<LatLng> setLocations(String coords){
    final splitted = coords.split('/');
    List <LatLng> list=[];
    for(int i=0;i<splitted.length-1;i++){
      if(i==0){
        final splitted2=splitted[i].split('-');
        print(splitted2[0]);
        LatLng place=new LatLng(double.parse(splitted2[0]),double.parse(splitted2[1]));
        list.add(place);
      }
      if(i==splitted.length-2){
        final splitted2=splitted[i].split('-');
        print(splitted2[0]);
        LatLng place2=new LatLng(double.parse(splitted2[0]),double.parse(splitted2[1]));
        list.add(place2);
      }
    }
    return list;
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
                              "??lanlar??m (??ahsi)",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.blue.withOpacity(.75),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Spacer(),
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
                        return Container(
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                              ],
                            ),
                          ),
                        );
                      }
                      if(snapshot.hasData && snapshot.data?.size==0){
                        return Container(
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Hi?? ??lan??n??z Yok",style: TextStyle(fontSize: 20),),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView(
                        children: snapshot.data!.docs.map((DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                          String start_location=data['start_location'];
                          String end_location=data['end_location'];
                          String date=data['date'];
                          String time=data['time'];
                          String price=data['price'];
                          String userId=data['user_id'];
                          String doc_id=document.id;
                          String coords=data['coord'];
                          return GestureDetector(
                            onTap: (){
                              //TIKLANILDI??I ZAMAN ??LAN DETAY SAYFASINA G??TMES?? ??????N GESTURE
                              List<LatLng>list=setLocations(coords);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DetailedListingPage(
                                listingId: document.id, coords:coords, list:list,
                              )));
                            },
                            child: buildTripCard(
                              context,
                              start_location: start_location,
                              end_location: end_location,
                              date: date,
                              time: time,
                              price: price,
                              userId: userId,
                              doc_id: doc_id,
                            ),
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

  Widget buildTripCard(
      BuildContext context,
      {
        required String start_location,
        required String end_location,
        required String date,
        required String time,
        required String price,
        required String userId,
        required String doc_id,

      } ) {

    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[

              // KALKI?? NOKTASI
              Padding(
                  padding: const EdgeInsets.only(top: 8.0,bottom: 6),
                  child: Row(children: <Widget>[
                    Icon(Icons.radio_button_checked,color: Colors.blue,),
                    Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left :4.0),
                          child: Text(
                            start_location,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: new TextStyle(fontSize: 17.0),
                          ),
                        )
                    ),
                  ])
              ),

              // DOTTED L??NE
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

              // VARI?? NOKTASI
              Padding(
                  padding: const EdgeInsets.only(top: 8.0,bottom: 6),
                  child: Row(children: <Widget>[
                    const Icon(Icons.location_on,color: Colors.red,),
                    Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left :4.0),
                          child: Text(
                            end_location,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: new TextStyle(fontSize: 17.0),
                          ),
                        )
                    ),
                  ])
              ),

              // SAAT - TAR??H
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
                        child: GestureDetector(
                          child: Icon(Icons.edit),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditListingPage(listingId: doc_id)));
                          },
                        )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        child: Icon(Icons.delete),
                        onTap: (){

                          Widget cancelButton = TextButton(
                            child: Text("??ptal"),
                            onPressed:  () {Navigator.pop(context);},
                          );
                          Widget continueButton = TextButton(
                            child: Text("Sil"),
                            onPressed:  () {
                              FirebaseFirestore.instance
                                  .collection('Listings')
                                  .doc(doc_id)
                                  .delete();
                              Navigator.pop(context);
                            },
                          );

                          // set up the AlertDialog
                          AlertDialog alert = AlertDialog(
                            title: Text("Uyar??"),
                            content: Text("??lan?? Kald??rmak ??stedi??inize emin misiniz?"),
                            actions: [
                              cancelButton,
                              continueButton,
                            ],
                          );
                          showDialog(
                              barrierDismissible: true,//tapping outside dialog will close the dialog if set 'true'
                              context: context,
                              builder: (context){
                                return alert;
                              }
                          );
                        },
                      )
                    ),
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
