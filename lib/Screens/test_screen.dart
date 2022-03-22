import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:ride_sharing_app/Screens/test_detail.dart';

class test_screen extends StatefulWidget {
  const test_screen({Key? key}) : super(key: key);

  @override
  _test_screenState createState() => _test_screenState();
}

class _test_screenState extends State<test_screen> {

  // !! API KEY SAKLANACAK UNUTMA
  String? googleApikey=dotenv.env['GOOGLE_API_KEY'];
  GoogleMapController? mapController; //contrller for Google map
  CameraPosition? cameraPosition;
  LatLng startLocation = LatLng(37.87121931889777, 32.505299407385266); // init map location (konya mevlana müzesi)

  String location = "Başlangıç Noktası";
  String location2= "Bitiş Noktası";

  var placeid1; // placeid for textfield1
  var placeid2; // placeid for textfield2



  // ------------------- marker işlemleri ------------------------------------//
  Set<Marker> markers = Set<Marker>(); // Marker list

  // default location marker
  @override
  void initState() {
    setMarker(LatLng(37.87121931889777, 32.505299407385266));
    super.initState();
  }

  // setmarker
  void setMarker(LatLng point){
    setState(() {
      markers.add(Marker(markerId: MarkerId('marker'),position:point,));
    });
  }

  // ------------------- ---------------- ------------------------------------//


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: Text("Konum Seç"),
        ),
        body: Stack(
            children:[

              GoogleMap( //Map widget from google_maps_flutter package
                zoomGesturesEnabled: true,
                markers: markers,
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


              //TEXTFIELD 1
              Positioned(  //search input bar
                  top:10,
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

                          //setMarker(newlatlang);

                          final Marker startMarker = Marker(
                            markerId: MarkerId("_kStartMarker"),
                            infoWindow: InfoWindow(title: "Başlangıç Noktası"),
                            icon: BitmapDescriptor.defaultMarker,
                            position: newlatlang, // ex loc 1 pos
                          );

                          setState(() {
                            markers.add(startMarker);
                            placeid1=placeid;
                          });


                          //move map camera to selected place with animation
                          mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: newlatlang, zoom: 17)));
                        }
                      },
                      child:Padding(
                        padding: EdgeInsets.all(15),
                        child: Card(
                          child: Container(
                              padding: EdgeInsets.all(0),
                              width: MediaQuery.of(context).size.width - 40,
                              child: ListTile(
                                title:Text(location, style: TextStyle(fontSize: 17),),
                                trailing: Icon(Icons.search),
                                dense: true,
                              )
                          ),
                        ),
                      )
                  )
              ),

              // TEXTFIELD 2

              Positioned(  //search input bar
                  top:80,
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
                            location2 = place.description.toString();
                            String? str = place.structuredFormatting?.mainText as String;
                            location2=str;
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

                          //setMarker(newlatlang);

                          final Marker finishMarker = Marker(
                            markerId: MarkerId("_kFinishMarker"),
                            infoWindow: InfoWindow(title: "Varış Noktası"),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                            position: newlatlang, // ex loc 1 pos
                          );

                          setState(() {
                            markers.add(finishMarker);
                            placeid2=placeid;
                          });

                          //move map camera to selected place with animation
                          mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: newlatlang, zoom: 17)));
                        }
                      },
                      child:Padding(
                        padding: EdgeInsets.all(15),
                        child: Card(
                          child: Container(
                              padding: EdgeInsets.all(0),
                              width: MediaQuery.of(context).size.width - 40,
                              child: ListTile(
                                title:Text(location2, style: TextStyle(fontSize: 17),),
                                trailing: Icon(Icons.search),
                                dense: true,
                              )
                          ),
                        ),
                      )
                  )
              ),

              // NEXT BUTTON
              Positioned(
                  top:165,
                  right: 20,
                  child: ElevatedButton(
                      child: Text("Yolculuk Bilgilerini Gir"),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage()));
                      },
                  )
              ),

            ]
        )
    );
  }
}

