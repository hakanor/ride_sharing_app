import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
class LocationTest extends StatefulWidget {
  const LocationTest({Key? key}) : super(key: key);

  @override
  _LocationTestState createState() => _LocationTestState();
}

class _LocationTestState extends State<LocationTest> {
  String? googleApikey=dotenv.env['GOOGLE_API_KEY'];
  String location = "Bir nokta seçin";
  LatLng place1=LatLng(37.87121931889777, 32.505299407385266);
  double results=0;

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Center(
          child:Column(
              children: [
                Container(  //search input bar
                    padding: EdgeInsets.all(25),
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
                            setState(() {
                              place1=newlatlang;
                            });

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

                Container(
                  width: 300,
                    padding:EdgeInsets.all(20),child: Text("Seçtiğiniz nokta :\n $place1",style: TextStyle(fontSize: 20),)),

                Container(
                  width: 300,
                    padding:EdgeInsets.all(20),child:
                Text("Kaynak nokta :\n38.00770809020045,\n"
                    "32.51868321147034",style: TextStyle(fontSize: 20),)),
                Text("km : $results",style: TextStyle(fontSize: 22,color: Colors.red,fontWeight: FontWeight.bold),),

                ElevatedButton(onPressed: (){
                  setState(() {
                    results=calculateDistance(place1.latitude, place1.longitude, 38.00770809020045, 32.51868321147034,);
                  });
                }, child: Text("Hesapla"),),
              ],

          )
        ),
      ),
    );
  }
}
