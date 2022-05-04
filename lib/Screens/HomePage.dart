import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:ride_sharing_app/Services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Chat Screens/ConversationPage.dart';
import 'FindNearestPage.dart';

// BU SAYFA İLANLARIN GENEL OLARAK LİSTELENDİĞİ SAYFA OLACAKTIR.

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late LatLng place_latlng;
  String? googleApikey=dotenv.env['GOOGLE_API_KEY'];
  var placeid;
  String location = "Gitmek İstediğiniz Yer?";

  AuthService auth =AuthService();
  String name_surname_current="";
  String currentUserId="";

  void yazigetir(String userId)async{
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get().then((value) {
      name_surname_current=value.data()!['name']+" "+value.data()!['surname'];
    });
  }


  @override
  void initState() {
    currentUserId=auth.UserIdbul();
    yazigetir(currentUserId);
    super.initState();
  }



  TextEditingController controller = TextEditingController();
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

  Future<String> getNameSurname (String userid) async {
    String name_surname="";
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userid)
        .get().then((value) {
      name_surname=value.data()!['name']+" "+value.data()!['surname'];
      print(name_surname);
    });
    return name_surname;
  }

  void search(String text){
      setState(() {
        _usersStream = FirebaseFirestore.instance.
        collection('Listings').
        where("end_location",isEqualTo: text).
        snapshots();
      });
  }

  void resetFilters(){
    setState(() {
      _usersStream = FirebaseFirestore.instance.
      collection('Listings').
      orderBy("date",descending: true).
      orderBy("time").snapshots();
      controller.text="";
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
              /*
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
              */
              Row(
                children: [
                  Container(  //search input bar
                      child: InkWell(
                          onTap: () async {
                            var place = await PlacesAutocomplete.show(
                                context: context,
                                apiKey: googleApikey,
                                mode: Mode.overlay,
                                language: "tr",
                                types: [],
                                strictbounds: false,
                                components: [Component(Component.country, 'tr')],
                                //google_map_webservice package
                                onError: (err){
                                  print(err);
                                }
                            );

                            if(place != null){
                              setState(() {
                                location = place.description.toString();
                                String? str = place.structuredFormatting?.mainText as String;
                                location=str;
                                controller.text=str;
                                search(str);
                              });

                              //form google_maps_webservice package
                              final plist = GoogleMapsPlaces(apiKey:googleApikey,
                                apiHeaders: await GoogleApiHeaders().getHeaders(),
                                //from google_api_headers package
                              );
                              String placeid = place.placeId ?? "0";
                              final detail = await plist.getDetailsByPlaceId(placeid);
                              final geometry = detail.result.geometry!;
                              final lat = geometry.location.lat;
                              final lang = geometry.location.lng;
                              var newlatlang = LatLng(lat, lang);
                              place_latlng=newlatlang;
                              setState(() {
                                placeid=placeid;
                              });
                            }
                          },

                          child:Padding(
                            padding: EdgeInsets.only(left:7),
                            child: Card(
                              child: Container(
                                width: MediaQuery.of(context).size.width - 80,
                                height: 40,
                                child: TextField(
                                  controller: controller,
                                  enabled: false,
                                  decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.search),
                                      hintText: "Nereye Gitmek İstiyorsunuz?",
                                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide(color: Colors.transparent),
                                      )
                                  ),
                                ),

                              ),
                            ),
                          )
                      )
                  ),

                  ElevatedButton(//RESET FILTER BUTTON
                    onPressed: () {
                      setState(() {
                        resetFilters();
                      });
                    },
                    child: Icon(Icons.clear),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(CircleBorder()),
                      padding: MaterialStateProperty.all(EdgeInsets.all(3)),
                      backgroundColor: MaterialStateProperty.all(Colors.blue), // <-- Button color
                      overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(MaterialState.pressed)) return Colors.red; // <-- Splash color
                      }),
                    ),
                  ),

                ],
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
                                child: Text("Eşleşen ilan yok",style: TextStyle(fontSize: 20),),
                              ),
                              ElevatedButton(
                                child: Text("Yakın arama yap"),
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => FindNearestPage(place_latlng: place_latlng,)));
                                },
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
                        String name_surname=data['name_surname'];
                        String userId=data['user_id'];
                        return GestureDetector(
                          onTap: () async {
                            //TIKLANILDIĞI ZAMAN İLAN DETAY SAYFASINA GİTMESİ İÇİN GESTURE
                            Fluttertoast.showToast(msg: document.id);
                            final FirebaseAuth _auth = FirebaseAuth.instance;
                            var ref =FirebaseFirestore.instance.collection('Conversations');
                            var documentRef = await ref.add(
                              {
                                'displayMessage':'',
                                'members':[userId,_auth.currentUser?.uid],
                                'name_surname':name_surname,
                                'name_surname2':name_surname_current,
                              }
                            );//CONVERSATION OLUSTURULDU

                            //ŞİMDİ DE DİREKT SAYFAYA GİDİLİYOR.
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationPage(
                              userId: userId,
                              conversationId: documentRef.id,
                            )));


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
