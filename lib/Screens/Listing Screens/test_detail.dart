import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatefulWidget {

  String start_location,end_location;

  DetailPage({required this.start_location,required this.end_location});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  void initState(){
    _timeinput.text="";
    _dateinput.text="";
    super.initState();
  }
  TextEditingController _timeinput = new TextEditingController();
  TextEditingController _dateinput = new TextEditingController();
  TextEditingController _seatcount = new TextEditingController();
  TextEditingController _carbrand = new TextEditingController();
  TextEditingController _carmodel = new TextEditingController();
  TextEditingController _platenumber = new TextEditingController();
  TextEditingController _price = new TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future createListing(String start_location,String end_location,String date, String time, int seat_count,String car_brand,String car_model,String platenumber) async {
    try{
      var currentUser = _auth.currentUser;
      await _firestore
          .collection("Listings")
          .doc()
          .set({
        'start_location': start_location,
        'end_location': end_location,
        'date': date,
        'time': time,
        'seat_count':seat_count,
        "car_brand":car_brand,
        "car_model":car_model,
        "user_id":currentUser?.uid,
        "platenumber":platenumber,
      });

    } on FirebaseAuthException catch(error){
      String? error_message=error.message;
      Fluttertoast.showToast(msg: "Error : $error_message");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text("İlan Detaylarını Gir"),),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 40,
                    width: 350,
                    child: TextFormField(
                      controller: _timeinput,
                      readOnly: true,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: (){
                            setState(() {
                              _timeinput.text="";
                            });
                          },
                        ),
                        labelText: "Çıkış Saati Seçin",
                        labelStyle: TextStyle(fontSize: 16),
                        border: OutlineInputBorder(),
                      ),
                      onTap: () async {
                        TimeOfDay? pickedTime=await showTimePicker(
                          helpText: "Çıkış saati Seçin",
                            cancelText: "İptal",
                            confirmText: "Onayla",
                            hourLabelText: "Saat",
                            minuteLabelText: "Dakika",
                            context: context,
                            initialTime: TimeOfDay.now(),
                            initialEntryMode: TimePickerEntryMode.dial,
                            builder: (context,child){
                              return MediaQuery(
                                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                  child: child ?? Container(),)
                            }
                        );

                        if(pickedTime != null ){

                          String _hour = pickedTime.hour.toString();
                          String _minute = pickedTime.minute.toString();
                          if(pickedTime.hour<10){
                            _hour="0"+_hour;
                          }
                          if(pickedTime.minute<10){
                            _minute="0"+_minute;
                          }

                          String formattedTime = _hour + ':' + _minute;
                          print(formattedTime);

                          setState(() {
                            _timeinput.text=formattedTime;
                          });
                        }else{
                          print("Saat Seçilmedi");
                        }
                      },
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 40,
                    width: 350,
                    child: TextField(
                      controller: _dateinput,
                      readOnly: true,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: (){
                            setState(() {
                              _dateinput.text="";
                            });
                          },
                        ),
                        labelText: "Çıkış Tarihi Seçin",
                        labelStyle: TextStyle(fontSize: 16),
                        border: OutlineInputBorder(),
                      ),
                      onTap: () async {
                        DateTime? pickedDate=await showDatePicker(
                            locale: const Locale("tr", "TR"),
                            helpText: "Yolculuk için tarih seçiniz.",
                            cancelText: "İptal",
                            confirmText: "Onayla",
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                        );
                        if(pickedDate != null ){
                          print(pickedDate);
                          String formattedDate = DateFormat('dd.MM.yyyy').format(pickedDate);
                          print(formattedDate);
                          setState(() {
                            _dateinput.text=formattedDate;
                          });
                        }else{
                          print("Tarih Seçilmedi");
                        }
                      },
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 40,
                    width: 350,
                    child: TextFormField(
                      controller: _seatcount,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Kaç Kişilik yeriniz var?",
                        labelStyle: TextStyle(fontSize: 16,),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 40,
                    width: 350,
                    child: TextFormField(
                      controller:_carbrand,
                      decoration: InputDecoration(
                        labelText: "Araç Markası Girin",
                        labelStyle: TextStyle(fontSize: 16),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 40,
                    width: 350,
                    child: TextFormField(
                      controller: _carmodel,
                      decoration: InputDecoration(
                        labelText: "Araç Modeli Girin",
                        labelStyle: TextStyle(fontSize: 16),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 40,
                    width: 350,
                    child: TextFormField(
                      controller: _platenumber,
                      decoration: InputDecoration(
                        labelText: "Araç Palakası Giriniz",
                        labelStyle: TextStyle(fontSize: 16),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left:0,top: 0),
                  child: Row(
                    children: [

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 40,
                          width: 125,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _price,
                            decoration: InputDecoration(
                              labelText: "Ücret Giriniz",
                              labelStyle: TextStyle(fontSize: 16),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),

                      Container(
                        height: 40,
                        width: 150,
                        child: Center(child: Text("",style: TextStyle(color: Colors.black87),)),
                      ),
                    ],
                  )
                ),

                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      child: Text("İlan Ver"),
                      onPressed: (){
                            if (_timeinput.text==null || _dateinput.text==null || _seatcount.text==null
                                || _carbrand.text==null || _carmodel.text==null || _platenumber.text==null
                                || _timeinput.text=="" || _dateinput.text==""
                            ) {
                              Fluttertoast.showToast(msg: "Tüm alanların doldurulması gerekmektedir.");
                            }
                            else{
                              try{
                                createListing(
                                  widget.start_location,
                                  widget.end_location,
                                  _dateinput.text,
                                  _timeinput.text,
                                  int.parse(_seatcount.text),
                                  _carbrand.text,
                                  _carmodel.text,
                                  _platenumber.text,
                                );
                                Navigator.popUntil(context, (route) =>route.isFirst);
                                Fluttertoast.showToast(msg: "İlan başarıyla oluşturuldu.");
                              } catch(error){
                                Fluttertoast.showToast(msg: "Tüm alanların doldurulması gerekmektedir.");
                              }
                            }

                      },
                    ),
                  ),
                ),
              ],

            ),
          ),
        ),
      ),
    );
  }
}
