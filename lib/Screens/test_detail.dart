import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text("İlan Detaylarını Gir"),),
      body: Center(
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
                  child: TextField(
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

                        String formattedTime = _hour + ' : ' + _minute;
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

              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    child: Text("İlan Ver"),
                    onPressed: (){

                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    child: Text("Test Ver"),
                    onPressed: (){

                    },
                  ),
                ),
              ),

              ElevatedButton(onPressed: (){
                print(widget.start_location);
              }, child: Text("selam"))
            ],

          ),
        ),
      ),
    );
  }
}
