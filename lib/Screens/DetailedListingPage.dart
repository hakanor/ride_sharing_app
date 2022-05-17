import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Listing{
  String car_brand="";
  String car_model="";
  String date="";
  String time="";
  String plate_number="";
  String price="";
  String seat_count="";
  String start_location="";
  String end_location="";
  String user_id="";
}

class DetailedListingPage extends StatefulWidget {
  final String listingId;
  const DetailedListingPage({Key? key, required this.listingId}) : super(key: key);

  @override
  _DetailedListingPageState createState() => _DetailedListingPageState();
}

class _DetailedListingPageState extends State<DetailedListingPage> {
  Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.
  collection('Listings').snapshots();

  Listing listing=new Listing();
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
    super.initState();
  }

  Future <Listing> getListing(String listingId)async{
    FirebaseFirestore.instance
        .collection('Listings')
        .doc(listingId)
        .get().then((value) {
      listing.car_brand=value.data()!['car_brand'];
      listing.car_model=value.data()!['car_model'];
      listing.date=value.data()!['date'];
      listing.time=value.data()!['time'];
      listing.plate_number=value.data()!['plate_number'];
      listing.price=value.data()!['price'];
      listing.seat_count=value.data()!['seat_count'].toString();
      listing.start_location=value.data()!['start_location'];
      listing.end_location=value.data()!['end_location'];
      listing.user_id=value.data()!['user_id'];
    });
    return listing;
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

  void setPolylines() async{
    _polylines.clear();
    polylineCoordinates.clear();

    PolylineResult result=await polylinePoints.getRouteBetweenCoordinates(
      googleApikey!,
      PointLatLng(place1.latitude, place1.longitude),
      PointLatLng(place2.latitude, place2.longitude),
    );
    print(result.status);
    print(result.errorMessage);
    if (result.status=='OK'){
      result.points.forEach((PointLatLng point) {polylineCoordinates.add(LatLng(point.latitude, point.longitude)); });
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
              leading: ElevatedButton(onPressed: (){

              },child: Text("test2"),),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(widget.listingId),
                  background: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap( //Map widget from google_maps_flutter package
                      zoomGesturesEnabled: true,
                      markers: markers,
                      polylines: _polylines,
                      initialCameraPosition: CameraPosition( //innital position in map
                        target: startLocation, //initial position
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
              child: buildListingCard(context, listingId: widget.listingId),
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

    } ) {
  return Container(
    height: 615,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.only(top:16.0,right: 16,left: 16,bottom: 16),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0,bottom: 6),
              child: Row(children: <Widget>[
                Icon(Icons.radio_button_checked,color: Colors.blue,),
                Padding(
                  padding: const EdgeInsets.only(left:4.0),
                  child: FutureBuilder<String>(
                    future: getKeyword(listingId,"car_brand"), // async work
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting: return CircularProgressIndicator();
                        default:
                          if (snapshot.hasError)
                            return Text('Error: ${snapshot.error}');
                          else{
                            String? name_surname_from_users=snapshot.data;
                            return Text(name_surname_from_users!);
                          }
                      }
                    },
                  ),
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
                  child: Text("listing.end_location", style: new TextStyle(fontSize: 17.0),),
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
                  child: Text("listing.time", style: new TextStyle(fontSize: 17.0),),
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
                  child: Text("listing.date", style: new TextStyle(fontSize: 17.0),),
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
                  child: Text("listing.car_brand+" "+listing.car_model", style: new TextStyle(fontSize: 17.0),),
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
                  child: Text("listing.plate_number", style: new TextStyle(fontSize: 17.0),),
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
                  child: Text("listing.seat_count", style: new TextStyle(fontSize: 17.0),),
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
                  child: Text("listing.price", style: new TextStyle(fontSize: 17.0),),
                ),
                //Spacer(),
              ]),
            ),

          ],
        ),
      ),
    ),
  );
}

Future <String> getKeyword(String listingId,String keyword)async{
  String variable="";
  FirebaseFirestore.instance
      .collection('Listings')
      .doc(listingId)
      .get().then((value) {
    variable=value.data()![keyword];
    print(variable);
  });
  return variable;
}