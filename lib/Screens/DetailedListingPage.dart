import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetailedListingPage extends StatefulWidget {
  final String listingId;
  final String coords;
  final List<LatLng> list;
  const DetailedListingPage({Key? key, required this.listingId, required this.coords,required this.list}) : super(key: key);

  @override
  _DetailedListingPageState createState() => _DetailedListingPageState();
}



class _DetailedListingPageState extends State<DetailedListingPage> {
  CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('Listings');

  String listingId="";
  String? googleApikey=dotenv.env['GOOGLE_API_KEY'];
  GoogleMapController? mapController; //controller for Google map
  CameraPosition? cameraPosition;
  Set<Marker> markers = Set<Marker>(); // Marker list
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints= PolylinePoints();

  LatLng startLocation = LatLng(37.87121931889777, 32.505299407385266);//TODO SİLİNECEK

  late LatLng place1; // textfield1 için place LatLng
  late LatLng place2; // textfield2 için place LatLng


  @override
  void initState() {
    listingId=widget.listingId;
    setState(() {
      place1=widget.list[0];
      place2=widget.list[1];
      setMarker(place1);
      setMarker(place2);
      print(widget.list.length);
      print(place1);
      setLocations();
    });
    //setPolylines();
    super.initState();
  }

  void setLocations()async{
    final splitted = widget.coords.split('/');
    for(int i=0;i<splitted.length-1;i++){
      final splitted2=splitted[i].split('-');
      print(splitted2[0]);
      LatLng place=new LatLng(double.parse(splitted2[0]),double.parse(splitted2[1]));
      setState(() {
        polylineCoordinates.add(place);
      });
      if(i==0){
          place1=place;
      }
      if(i==splitted.length-1){
          place2=place;
      }
    }
    setState(() {
      _polylines.add(
          Polyline(
            width: 6,
            polylineId: PolylineId('polyLine'),
            color: Color(0xFF08A5CB),
            points: polylineCoordinates,
          )
      );
    });
  }

  void setMarker(LatLng point){
    setState(() {
      markers.add(
          Marker(
            markerId: MarkerId('marker'),
            position:point,
          )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              floating:false,
              leading: GestureDetector(
                  child: Icon(Icons.arrow_back_ios_outlined,color: Colors.black,),
                onTap: (){
                    Navigator.pop(context);
                },
              ),

              title: Text("İlan Detayları",style: TextStyle(color: Colors.black87),),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                //title: Text(widget.listingId),
                  background: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap( //Map widget from google_maps_flutter package
                      zoomGesturesEnabled: true,
                      rotateGesturesEnabled: false,
                      scrollGesturesEnabled: true,
                      gestureRecognizers: Set()
                        ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
                        ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
                        ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
                        ..add(Factory<VerticalDragGestureRecognizer>(
                                () => VerticalDragGestureRecognizer())),
                      markers: markers,
                      polylines: _polylines,
                      initialCameraPosition: CameraPosition( //innital position in map
                        target: place1, //initial position
                        zoom: 14.0, //initial zoom level
                      ),
                      mapType: MapType.normal, //map type
                      onMapCreated: (controller) { //method called when map is created
                        setState(() {
                          mapController = controller;
                        });
                      },
                    ),
                  ),
              ),

            ),
            SliverToBoxAdapter(
              child: StreamBuilder<DocumentSnapshot>(
                stream: usersCollection.doc(widget.listingId).snapshots(),
                builder: (ctx, streamSnapshot) {
                  if (streamSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    );
                  }
                  return buildListingCard(context, listingId: listingId, snapshot: streamSnapshot);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}


Widget buildListingCard(
    BuildContext context,
    {
      required String listingId,
      required AsyncSnapshot snapshot,

    } ) {
  return Container(
    height: 615,
    child: Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top:16.0,right: 16,left: 16,bottom: 16),
        child: Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(top: 8.0,bottom: 6),
                child: Row(children: <Widget>[
                  Icon(Icons.radio_button_checked,color: Colors.blue,),
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left :4.0),
                        child: Text(
                          snapshot.data!['start_location'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: new TextStyle(fontSize: 17.0),
                        ),
                      )
                  ),
                ])
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
                padding: const EdgeInsets.only(top: 8.0,bottom: 6),
                child: Row(children: <Widget>[
                  const Icon(Icons.location_on,color: Colors.red,),
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left :4.0),
                        child: Text(
                          snapshot.data!['end_location'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: new TextStyle(fontSize: 17.0),
                        ),
                      )
                  ),
                ])
            ),

            Padding(
              padding: const EdgeInsets.only(top:20,),
              child: Row(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left:4.0),
                  child: Text("Tarih Bilgileri",
                    style: new TextStyle(
                        color: Colors.black87,
                        fontSize: 16.0,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                //Spacer(),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 4.0,top: 8),
              child: Row(children: <Widget>[
                const Icon(Icons.alarm,color: Colors.red,),
                Padding(
                  padding: const EdgeInsets.only(left:4.0),
                  child: Text(snapshot.data!['time'], style: new TextStyle(fontSize: 17.0),),
                ),
                //Spacer(),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0,top: 8),
              child: Row(children: <Widget>[
                const Icon(Icons.calendar_month,color: Colors.red,),
                Padding(
                  padding: const EdgeInsets.only(left:4.0),
                  child: Text(snapshot.data!['date'], style: new TextStyle(fontSize: 17.0),),
                ),
                //Spacer(),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.only(top:20,),
              child: Row(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left:4.0),
                  child: Text("Araç Bilgileri",
                    style: new TextStyle(
                      fontSize: 16.0,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                //Spacer(),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 4.0,top: 8),
              child: Row(children: <Widget>[
                const Icon(Icons.directions_car,color: Colors.red,),
                Padding(
                  padding: const EdgeInsets.only(left:4.0),
                  child: Text(snapshot.data!['car_brand']+" "+snapshot.data!['car_model']+" marka model araç.", style: new TextStyle(fontSize: 17.0),),
                ),
                //Spacer(),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0,top: 8),
              child: Row(children: <Widget>[
                const Icon(Icons.directions_car,color: Colors.red,),
                Padding(
                  padding: const EdgeInsets.only(left:4.0),
                  child: Text(snapshot.data!['platenumber']+" plakalı araç.", style: new TextStyle(fontSize: 17.0),),
                ),
                //Spacer(),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.only(top:20,),
              child: Row(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left:4.0),
                  child: Text("Yolculuk Bilgileri",
                    style: new TextStyle(
                      fontSize: 16.0,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                //Spacer(),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 4.0,top: 8),
              child: Row(children: <Widget>[
                const Icon(Icons.airline_seat_recline_normal,color: Colors.red,),
                Padding(
                  padding: const EdgeInsets.only(left:4.0),
                  child: Text(snapshot.data!['seat_count'].toString()+" adet boş koltuk.", style: new TextStyle(fontSize: 17.0),),
                ),
                //Spacer(),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0,top: 8),
              child: Row(children: <Widget>[
                Container(
                  child: Image(image: AssetImage('assets/play_store_513.png'),),
                  height: 20,
                  width: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Text(snapshot.data!['price']+" TL kişi başı ücret.", style: new TextStyle(fontSize: 17.0),),
                ),
                //Spacer(),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.only(top:20,),
              child: Row(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left:4.0),
                  child: Text("Sürücü Bilgileri",
                    style: new TextStyle(
                      fontSize: 16.0,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                //Spacer(),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 4.0,top: 8),
              child: Row(children: <Widget>[
                Container(
                  child: FutureBuilder<String>(
                    future: getData(snapshot.data!['user_id'],"Image"), // async work
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
                ),
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child:  FutureBuilder<String>(
                    future: getData(snapshot.data!['user_id'],"name"), // async work
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting: return CircularProgressIndicator();
                        default:
                          if (snapshot.hasError)
                            return Text('Error: ${snapshot.error}');
                          else{
                            String? data=snapshot.data;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(data!,style: new TextStyle(fontSize: 17.0),),
                              ],
                            );
                          }
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child:  FutureBuilder<String>(
                    future: getData(snapshot.data!['user_id'],"surname"), // async work
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting: return CircularProgressIndicator();
                        default:
                          if (snapshot.hasError)
                            return Text('Error: ${snapshot.error}');
                          else{
                            String? data=snapshot.data;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(data!,style: new TextStyle(fontSize: 17.0),),
                              ],
                            );
                          }
                      }
                    },
                  ),
                ),
              ]),
            ),

          ],
        ),
      ),
    ),
  );
}

Future<String> getData(String id,String keyword) async {
  String b="";
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(id)
      .get().then((value) {
    b=value.data()![keyword];
  });
  return b;
}

Widget buildCardTile(
    {
      required String desc,
      required String text,
      required String text2,
      required Function onPress,
      required IconData icon,
      required IconData icon2,
    }) {
  return Padding(
    padding: const EdgeInsets.only(top:8.0),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6,left: 4),
            child: Text(
              desc,
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w400,
                fontSize: 15,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top:3.0,left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: Colors.blue,
                ),
                Padding(
                  padding: const EdgeInsets.only(left :8.0),
                  child: Text(
                    text,
                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top:7.0,left :4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon2,
                  size: 18,
                  color: Colors.blue,
                ),
                Padding(
                  padding: const EdgeInsets.only(left :8.0),
                  child: Text(
                    text2,
                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}