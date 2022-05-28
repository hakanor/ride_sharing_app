import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'Chat Screens/ConversationPage.dart';
import 'DetailedListingPage.dart';

class Listing{
  late String doc_id;
  late String car_brand;
  late String start_location;
  late String end_location;
  late String date;
  late String time;
  late String price;
  late String name_surname;
  late String userId;
  late String distance;
  late String coord;
  late double minresult;
}
class FindNearestLocationPage extends StatefulWidget {
  LatLng place_latlng;
  LatLng location_latlng;
  final String placename;
  FindNearestLocationPage({required this.place_latlng, required this.placename,required this.location_latlng});

  @override
  _FindNearestLocationPageState createState() => _FindNearestLocationPageState();
}

class _FindNearestLocationPageState extends State<FindNearestLocationPage> {

  String currentUserId="";
  String name_surname_current="";

  TextEditingController controller = TextEditingController();
  Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.
  collection('Listings').snapshots();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  Future <String> getData2(List<String> members, String start_location) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Conversations').get();

    final allData =
    querySnapshot.docs.map((doc) => doc.get('members')).toList();
    final allData2 =
    querySnapshot.docs.map((doc) => doc.get('start_location')).toList();
    final allData3 =
    querySnapshot.docs.map((doc) => doc.id).toList();

    for(int i=0;i<allData.length;i++){
      if(allData[i][0]==members[0]&& allData[i][1]==members[1]){
        if(allData2[i]==start_location){
          return allData3[i].toString();
        }
      }
    }
    return "true";
  }

  List<LatLng> setLocations(String coords){
    final splitted = coords.split('/');
    List <LatLng> list=[];
    for(int i=0;i<splitted.length-1;i++){
      if(i==0){
        final splitted2=splitted[i].split('-');
        LatLng place=new LatLng(double.parse(splitted2[0]),double.parse(splitted2[1]));
        list.add(place);
      }
      if(i==splitted.length-2){
        final splitted2=splitted[i].split('-');
        LatLng place2=new LatLng(double.parse(splitted2[0]),double.parse(splitted2[1]));
        list.add(place2);
      }
    }
    return list;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future <void> updatePosition() async {
    Position position = await _determinePosition();
  }



  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }


  void yazigetir(String userId)async{
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get().then((value) {
      name_surname_current=value.data()!['name']+" "+value.data()!['surname'];
    });
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
                  EdgeInsets.only(top: size.height * .06),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: ((size.width)-40)/3,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              onPressed: () {Navigator.pop(context);},
                              icon: Icon(
                                Icons.arrow_back_ios_outlined,
                                color: Colors.blue.withOpacity(.75),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  "Konumunuza Göre",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue.withOpacity(.75),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Yakın İlanlar",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue.withOpacity(.75),
                                      fontWeight: FontWeight.bold),
                                ),


                              ],
                            )
                          ),
                        ),
                        Container(
                          width: ((size.width)-40)/3,
                          child: GestureDetector(
                            onTap:(){
                              AlertDialog alert = AlertDialog(
                                title: Text("Km Hesabı Neye Göre Yapılıyor?"),
                                content: Text("Bu sayfada gösterilen km verileri kuş uçuşu uzaklığı baz almaktadır."),
                              );
                              showDialog(
                                  barrierDismissible: true,//tapping outside dialog will close the dialog if set 'true'
                                  context: context,
                                  builder: (context){
                                    return alert;
                                  }
                              );
                            },
                              child: Container(
                                  child: Icon(Icons.question_mark,color: Colors.blue,),
                              )
                          ),
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
                      else{
                        var x = snapshot.data!.docs.map((DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                          String doc_id=document.id;
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
                            double result=calculateDistance(widget.place_latlng.latitude, widget.place_latlng.longitude, double.parse(splitted2[0]), double.parse(splitted2[1]));
                            double minresult=1;

                            if(result<1 && start_location!= widget.placename){
                              for(int j=0; j<1; j++){
                                String y = splitted[j];
                                var splitted2=y.split('-');
                                double resultMin=calculateDistance(widget.location_latlng.latitude, widget.location_latlng.longitude, double.parse(splitted2[0]), double.parse(splitted2[1]));
                                minresult=resultMin;
                              }
                              Listing l1=new Listing();
                              l1.doc_id=doc_id;
                              l1.date=date;
                              l1.start_location=start_location;
                              l1.end_location=end_location;
                              l1.userId=userId;
                              l1.price=price;
                              l1.name_surname=name_surname;
                              l1.time=time;
                              l1.coord=coord;
                              l1.minresult=minresult;
                              return l1;
                            }
                          }
                          return null;
                        }).toList();

                        for(int i=0;i<x.length;i++){
                          if(x[i]==null){
                            x.removeAt(i);
                            i--;
                          }
                        }

                        x.sort((a,b)=> a!.minresult.compareTo(b!.minresult));

                        return ListView.builder(
                            itemCount: x.length,
                            itemBuilder: (context,index){
                              final item=x[index];
                              return GestureDetector(
                                child: buildTripCard(
                                  context,
                                  start_location: item!.start_location,
                                  end_location: item.end_location,
                                  date: item.date,
                                  time: item.time,
                                  price: item.price,
                                  name_surname: item.name_surname,
                                  userId: item.userId,
                                  minresult: item.minresult,
                                ),
                                onTap: (){
                                  //TODO TIKLANDILIĞI ZAMAN GİTMESİ İÇİN
                                  List<LatLng>list=setLocations(item.coord);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => DetailedListingPage(
                                    listingId: item.doc_id, coords:item.coord, list:list,
                                  )));
                                },
                              );
                            }
                        );

                      }
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
        required double minresult,

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
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0,top:4),
                    child: Row(
                      children: [
                        Text("Uzaklık : "),
                        Text(minresult.toStringAsFixed(2)+" km", style: new TextStyle(fontSize: 16.0,color:(minresult < 2 ? Colors.blue : Colors.red)),)
                      ],
                    ),
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

                    FutureBuilder<String>(
                      future: getImageUrl(userId), // async work
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting: return CircularProgressIndicator();
                          default:
                            if (snapshot.hasError)
                              return Text('Error: ${snapshot.error}');
                            else{
                              String? url=snapshot.data;
                              return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blue,width: 1),
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(.55),
                                          blurRadius: 10,
                                          spreadRadius: 2)
                                    ],
                                  ),
                                  height: 25,
                                  width: 25,
                                  child: CircleAvatar(
                                    backgroundImage:
                                    NetworkImage(url!),
                                  ),
                                ),
                              );
                            }
                        }
                      },
                    ),


                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FutureBuilder<String>(
                        future: getNameSurname(userId), // async work
                        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting: return CircularProgressIndicator();
                            default:
                              if (snapshot.hasError)
                                return Text('Error: ${snapshot.error}');
                              else{
                                String? name_surname_from_users=snapshot.data;
                                name_surname=snapshot.data!;
                                return Text(name_surname_from_users!);
                              }
                          }
                        },
                      ),
                    ),

                    GestureDetector(child: Icon(Icons.message_outlined),onTap: ()async{
                      final FirebaseAuth _auth = FirebaseAuth.instance;
                      var ref = FirebaseFirestore.instance.collection('Conversations');
                      var checker= await getData2([userId,_auth.currentUser!.uid],start_location);
                      print(checker);

                      if(checker!="true"){
                        if(userId==_auth.currentUser!.uid){
                          Fluttertoast.showToast(msg: "Kendinize mesaj gönderemezsiniz!"); //TODO DELETE IT LATER
                        }
                        else{
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationPage(
                            userId: userId,
                            conversationId: checker,
                          )));
                        }
                      }
                      else{
                        var documentRef = await ref.add(
                            {
                              'displayMessage':'',
                              'members':[userId,_auth.currentUser?.uid],
                              'name_surname':name_surname,
                              'name_surname2':name_surname_current,
                              'start_location':start_location,
                              'end_location':end_location,
                            }
                        );//CONVERSATION OLUSTURULDU

                        //ŞİMDİ DE DİREKT SAYFAYA GİDİLİYOR.
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationPage(
                          userId: userId,
                          conversationId: documentRef.id,
                        )));
                      }
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
