import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:ride_sharing_app/Screens/Create%20Listing%20Screens/test_detail.dart';

class test_screen extends StatefulWidget {
  final LatLng current_location_latlng;
  const test_screen({Key? key,required this.current_location_latlng}) : super(key: key);

  @override
  _test_screenState createState() => _test_screenState();
}

class _test_screenState extends State<test_screen> {
  String? googleApikey=dotenv.env['GOOGLE_API_KEY'];
  GoogleMapController? mapController; //controller for Google map
  CameraPosition? cameraPosition;
  LatLng startLocation = LatLng(37.87121931889777, 32.505299407385266);// init map location (konya mevlana müzesi)

  String location = "Başlangıç Noktası";
  String location2= "Bitiş Noktası";
  String city="";
  String city2="";

  var placeid1; // placeid for textfield1
  var placeid2; // placeid for textfield2

  late LatLng place1; // textfield1 için place LatLng
  late LatLng place2; // textfield2 için place LatLng

  // Google autocomplete textfield
  String start_location="";
  String end_location="";

  // konumu dışarıdan girerek yakın çevrede arama yapılmasını sağlıyor
  Future <List<String>> searchNearbyService(var lat, var lng) async{
    var dio= Dio();
    var url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json";
    var parameters={
      'key':googleApikey,
      'location':'$lat,$lng',
      'radius':100,
      'language':"tr",
    };
    var response = await dio.get(url,queryParameters: parameters);
    return response.data['results'].map<String>((result)=>result['name'].toString()).toList();
  }

  Future<void> GetAddressFromLatLong(LatLng position)async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude,localeIdentifier: "tr");
    print(placemarks);
    Placemark place = placemarks[0];
    //Address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(()  {
      location = '${place.street} Mah, ${place.thoroughfare}';
      city= place.administrativeArea!;
    });
  }

  // ------------------- marker işlemleri ------------------------------------//
  Set<Marker> markers = Set<Marker>(); // Marker list
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints= PolylinePoints();

  @override
  void initState() {
    startLocation=widget.current_location_latlng;
    polylinePoints = PolylinePoints();
    super.initState();
  }

  // setmarker
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
                polylines: _polylines,
                initialCameraPosition: CameraPosition( //innital position in map
                  target: startLocation, //initial position
                  zoom: 17.0, //initial zoom level
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

                          List splitted = detail.result.formattedAddress!.split(", Turkey");
                          List splitted2= splitted[0].split("/");
                          List splitted3= splitted2.last.split(", ");

                          final geometry = detail.result.geometry!;
                          final lat = geometry.location.lat;
                          final lang = geometry.location.lng;
                          var newlatlang = LatLng(lat, lang);
                          place1=newlatlang;


                          final Marker startMarker = Marker(
                            markerId: MarkerId("_kStartMarker"),
                            infoWindow: InfoWindow(title: "Başlangıç Noktası"),
                            icon: BitmapDescriptor.defaultMarker,
                            position: newlatlang, // ex loc 1 pos
                          );

                          setState(() {
                            markers.add(startMarker);
                            placeid1=placeid;
                            city=splitted3.last;
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
                                dense: true,
                                title:Text(location, style: TextStyle(fontSize: 17),),
                                trailing: Row(
                                  mainAxisSize:MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      child: Padding(padding: const EdgeInsets.only(right:10),
                                        child: Row(children: [Text("Konumu Kullan"),Icon(Icons.location_on)],)),
                                      onTap: () async{
                                        GetAddressFromLatLong(widget.current_location_latlng);
                                        List nearLocations;
                                        nearLocations = await searchNearbyService(widget.current_location_latlng.latitude, widget.current_location_latlng.longitude);
                                        nearLocations.insert(0,location);
                                        return showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('En Uygun Konumu Seçin'),
                                                content: Container(
                                                  width: double.minPositive,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: nearLocations.length,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      return ListTile(
                                                        title: Text(nearLocations[index]),
                                                        trailing: index == 0?
                                                        Icon(Icons.location_on,color: Colors.red,) //code if above statement is true
                                                            : null,
                                                        onTap: () {
                                                          setState(() {
                                                            location=nearLocations[index];
                                                            place1=widget.current_location_latlng;

                                                            final Marker startMarker = Marker(
                                                              markerId: MarkerId("_kStartMarker"),
                                                              infoWindow: InfoWindow(title: "Başlangıç Noktası"),
                                                              icon: BitmapDescriptor.defaultMarker,
                                                              position: widget.current_location_latlng, // ex loc 1 pos
                                                            );

                                                            setState(() {
                                                              markers.add(startMarker);
                                                              placeid1=location;
                                                            });

                                                            //move map camera to selected place with animation
                                                            mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: widget.current_location_latlng, zoom: 17)));

                                                          });
                                                          Navigator.pop(context, nearLocations[index]);
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                    ),
                                    Icon(Icons.search),
                                  ],
                                ),
                              ),
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

                          List splitted = detail.result.formattedAddress!.split(", Turkey");
                          List splitted2= splitted[0].split("/");
                          List splitted3= splitted2.last.split(", ");
                          city2=splitted3.last;

                          final geometry = detail.result.geometry!;
                          final lat = geometry.location.lat;
                          final lang = geometry.location.lng;
                          var newlatlang = LatLng(lat, lang);
                          place2=newlatlang;

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
                            setPolylines();
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
                        if(placeid1==null && placeid2==null){
                          Fluttertoast.showToast(msg: "Başlangıç ve Bitiş noktası belirtilmek zorunda!");
                        }
                        else if(placeid1==null){Fluttertoast.showToast(msg: "Başlangıç noktası belirtilmek zorunda!");}
                        else if(placeid2==null){Fluttertoast.showToast(msg: "Bitiş noktası belirtilmek zorunda!");}
                        else{
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(
                            start_location:location,
                            end_location: location2,
                            polylineCoordinates: polylineCoordinates ,
                            city: city==""?city2 : city,
                          )));
                        }
                      },
                  )
              ),
            ]
        )
    );
  }
}

