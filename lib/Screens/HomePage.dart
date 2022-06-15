import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:ride_sharing_app/Screens/DetailedListingPage.dart';
import 'package:ride_sharing_app/Services/auth_service.dart';
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

  String dropdownvalue = 'Şehir seçiniz';
  var items = [
    "Şehir seçiniz","Adana","Adıyaman","Afyon","Ağrı","Amasya","Ankara","Antalya","Artvin","Aydın","Balıkesir","Bilecik","Bingöl","Bitlis","Bolu","Burdur","Bursa","Çanakkale","Çankırı","Çorum",
    "Denizli","Diyarbakır", "Edirne","Elazığ","Erzincan","Erzurum","Eskişehir","Gaziantep","Giresun","Gümüşhane","Hakkari","Hatay","Isparta","Mersin","İstanbul","İzmir","Kars",
    "Kastamonu","Kayseri","Kırklareli","Kırşehir","Kocaeli","Konya","Kütahya","Malatya","Manisa","Kahramanmaraş","Mardin","Muğla","Muş","Nevşehir","Niğde","Ordu","Rize","Sakarya",
    "Samsun","Siirt","Sinop","Sivas","Tekirdağ","Tokat","Trabzon","Tunceli","Şanlıurfa","Uşak","Van","Yozgat","Zonguldak","Aksaray","Bayburt","Karaman","Kırıkkale","Batman",
    "Şırnak","Bartın","Ardahan","Iğdır","Yalova","Karabük","Kilis","Osmaniye","Düzce"
  ];

  void yazigetir(String userId)async{
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get().then((value) {
      name_surname_current=value.data()!['name']+" "+value.data()!['surname'];
    });
  }

  Future<void> getCity(String userId)async{
    String city="Şehir seçiniz";
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get().then((value) {
      city=value.data()!['city'];
      print(city);
    });
    setState(() {
      dropdownvalue=city;
    });
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
  void initState() {
    currentUserId=auth.UserIdbul();
    yazigetir(currentUserId);
    getCity(currentUserId);
    super.initState();
  }

  TextEditingController controller = TextEditingController();
  Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.
  collection('Listings').
  orderBy("date",descending: true).
  orderBy("time").snapshots();

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
      getCity(currentUserId);
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
              Row(
                children: [
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right :15.0),
                    child: DropdownButton(
                      value: dropdownvalue,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: items.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),

                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownvalue = newValue!;
                          _usersStream = FirebaseFirestore.instance.
                          collection('Listings').where("city",isEqualTo: dropdownvalue).snapshots();
                        });
                      },
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
                      if(controller.text==""){
                        return Container(
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Eşleşen ilan yok",style: TextStyle(fontSize: 20),),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      else{
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
                                    if(place_latlng!=null){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => FindNearestPage(
                                        place_latlng: place_latlng,
                                        placename: location,
                                      )));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }

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
                        String coords=data['coord'];
                        String city=data['city'];

                        if (controller.text!=""){
                            dropdownvalue="Şehir seçiniz";
                          return GestureDetector(
                            onTap: () async {
                              //TIKLANILDIĞI ZAMAN İLAN DETAY SAYFASINA GİTMESİ İÇİN GESTURE
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
                              name_surname: name_surname,
                              userId: userId,
                            ),
                          );
                        }
                        else{
                          if(city==dropdownvalue){
                            return GestureDetector(
                              onTap: () async {
                                //TIKLANILDIĞI ZAMAN İLAN DETAY SAYFASINA GİTMESİ İÇİN GESTURE
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
                                name_surname: name_surname,
                                userId: userId,
                              ),
                            );
                          }
                          else{
                            return Container();
                          }

                        }
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

                    // PROFILE PHOTO
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

                    //name_surname
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

                    // ICON SEND MESSAGE
                    GestureDetector(child: Icon(Icons.message_outlined),onTap: ()async{
                      final FirebaseAuth _auth = FirebaseAuth.instance;
                      var ref = FirebaseFirestore.instance.collection('Conversations');
                      var checker= await getData2([userId,_auth.currentUser!.uid],start_location);
                      if(checker!="true"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationPage(
                          userId: userId,
                          conversationId: checker,
                        )));
                      }
                      else if(userId==currentUserId){
                        Fluttertoast.showToast(msg: "Kendinize mesaj gönderemezsiniz!");
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

                      /* PHONE CALL FEATURE does not need anymore
                      String phoneNumber= await getPhoneNumber(userId);
                      _makePhoneCall(phoneNumber);
                       */

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
