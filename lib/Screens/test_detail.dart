import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  void initState(){
    _timeinput.text="";
    _dateinput.text="";
    super.initState();
  }

  DateTime? _dateTime;
  TextEditingController _dateinput = new TextEditingController();
  TextEditingController _timeinput = new TextEditingController();
  TextEditingController _count = new TextEditingController();

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
                      labelText: "Çıkış Saati Seçin",
                      labelStyle: TextStyle(fontSize: 16),
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      TimeOfDay? pickedTime=await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if(pickedTime != null ){
                        print(pickedTime.format(context));
                        DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                        print(parsedTime); //output 1970-01-01 22:53:00.000
                        String formattedTime = DateFormat('HH:mm').format(parsedTime);
                        print(formattedTime); //output 14:59:00
                        setState(() {
                          _timeinput.text=formattedTime;
                        });
                      }else{
                        print("Time is not selected");
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
                      labelText: "Çıkış Tarihi Seçin",
                      labelStyle: TextStyle(fontSize: 16),
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      DateTime? pickedDate=await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                      );
                      if(pickedDate != null ){
                        print(pickedDate);
                        String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                        print(formattedDate);
                        setState(() {
                          _dateinput.text=formattedDate;
                        });
                      }else{
                        print("Date is not selected");
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
                  child: TextField(
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
                  child: TextField(
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
                  padding: const EdgeInsets.only(right: 22),
                  child: ElevatedButton(
                    child: Text("İlan Ver"),
                    onPressed: (){

                    },
                  ),
                ),
              )


            ],

          ),
        ),
      ),
    );
  }
}
