import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConversationPage extends StatefulWidget {
  final String userId;
  final String conversationId;

  const ConversationPage({Key? key,required this.userId,required this.conversationId,}) : super(key: key);

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late CollectionReference _ref;
  final TextEditingController _editingController = TextEditingController();
  ScrollController _scrollController=ScrollController();
  FocusNode _focusNode=FocusNode();
  String name_surname="";
  String url="";
  String url2="https://firebasestorage.googleapis.com/v0/b/ride-sharing-app-389d2.appspot.com/o/avatar3.png?alt=media&token=7088e5e8-2fee-4f28-aad7-8bd53a0bacad";

  void yazigetir()async {

      String b="";
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get().then((value) {
        b=value.data()!['name']+ " " +value.data()!['surname'];
        setState(() {
          name_surname=b;
        });
    });
  }

    void getProfilePicture()async {
    String b="";
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .get().then((value) {
      b=value.data()!['Image'];
      setState(() {
        url=b;
      });
    });
  }


  @override
  void initState() {
    yazigetir();
    getProfilePicture();

    _ref=FirebaseFirestore.instance.collection('Conversations/${widget.conversationId}/messages');
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
      }else if (_scrollController.offset <= _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: -5,
        title: Row(
          children: [
            Container(child: CircleAvatar(
              backgroundImage: NetworkImage(url==""?url2 : url),
            ),height: 35,width: 35,),
            Padding(
              padding: const EdgeInsets.only(left:10.0),
              child: Text(name_surname),//TODO name_surname alınacak
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage("https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png"),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: GestureDetector(
                  onTap: (){
                    _focusNode.unfocus();
                  },
                  child: StreamBuilder(
                    //TODO ORDER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! timeFormat
                    //stream: _ref.orderBy('time',descending: true).orderBy('date',descending: true).snapshots(),
                      stream: _ref.orderBy('timeStamp',descending: true).snapshots(),
                    builder: (context, AsyncSnapshot <QuerySnapshot> snapshot) {
                      return !snapshot.hasData
                          ? Center(
                        child: CircularProgressIndicator(),
                      )
                          : ListView(
                              reverse: true,
                              controller: _scrollController,
                              children: snapshot.data?.docs.map((DocumentSnapshot document)=>ListTile(
                              title: Align(
                              alignment: widget.userId != document['senderId']
                                  ?Alignment.centerLeft
                                  :Alignment.centerRight,
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(bottom: 15,top: 8,right: 20,left: 8),
                                      decoration: BoxDecoration(
                                          color: widget.userId != document['senderId']
                                              ?Colors.blueGrey
                                              :Colors.blue,
                                          borderRadius: BorderRadius.only(
                                            topLeft:Radius.circular(13),
                                            topRight:Radius.circular(13),
                                            bottomLeft:widget.userId != document['senderId']
                                                ?Radius.circular(0)
                                                :Radius.circular(13),
                                            bottomRight: widget.userId != document['senderId']
                                                ?Radius.circular(13)
                                                :Radius.circular(0),
                                          ),
                                      ),
                                      child: Text(document['message'],style: TextStyle(color: Colors.white),),

                                    ),
                                    Positioned(bottom:0,right: 0,child: Padding(
                                      padding: const EdgeInsets.only(right: 6,bottom: 3),
                                      child: Text(document['time_formatted'],style: TextStyle(color: Colors.white,fontSize: 10),),
                                    )),
                                  ],
                                )
                          ),
                        )).toList() as List<Widget>,
                      );
                    }
                  ),
                ),
              ),
            ),

            // SEND TEXT FIELD
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(25),
                            right: Radius.circular(25),
                          ),
                      ),
                      child:  TextField(
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.send,
                        controller: _editingController,
                        onSubmitted: (value) async {// for keyboard ok button to send message
                          if(_editingController.text!=""){
                            var now = DateTime.now();
                            var formatter = new DateFormat('dd-MM-yyyy');
                            //var formatter = new DateFormat('yyyy-MM-dd');
                            String formattedDate = formatter.format(now);

                            String _hour = now.hour.toString();
                            String _minute = now.minute.toString();
                            String _seconds= now.second.toString();

                            if(now.hour<10){
                              _hour="0"+_hour;
                            }
                            if(now.minute<10){
                              _minute="0"+_minute;
                            }
                            if(now.second<10){
                              _seconds="0"+_seconds;
                            }
                            String time= _hour+ ":" +_minute +":"+_seconds;
                            String time_formatted= _hour+ ":" +_minute;

                            await _ref.add({
                              'senderId' : widget.userId,
                              'message' : _editingController.text,
                              'timeStamp' : DateTime.now(),
                              'date':formattedDate,
                              'time':time,
                              'time_formatted':time_formatted,
                            });

                            var collection = FirebaseFirestore.instance.collection('Conversations');
                            collection
                                .doc(widget.conversationId) // <-- Doc ID where data should be updated.
                                .update({
                                  'displayMessage' : _editingController.text,
                                  'time':time,
                                  'time_formatted':time_formatted,
                                  }) // <-- Nested value
                                .catchError((error) => print('Update failed: $error'));

                            _editingController.text="";
                            _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: Duration(milliseconds: 200),
                                curve: Curves.easeOut);

                          }
                        },
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(left: 20),
                            hintText: "Bir mesaj gönderin",
                            border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: ElevatedButton(
                      onPressed: () async {
                        if(_editingController.text!=""){
                          var now = DateTime.now();
                          var formatter = new DateFormat('dd-MM-yyyy');
                          String formattedDate = formatter.format(now);

                          String _hour = now.hour.toString();
                          String _minute = now.minute.toString();
                          String _seconds = now.second.toString();

                          if(now.hour<10){
                            _hour="0"+_hour;
                          }
                          if(now.minute<10){
                            _minute="0"+_minute;
                          }
                          String time= _hour+ ":" +_minute+":"+_seconds;
                          String time_formatted= _hour+ ":" +_minute;

                          await _ref.add({
                            'senderId' : widget.userId,
                            'message' : _editingController.text,
                            'timeStamp' : DateTime.now(),
                            'date':formattedDate,
                            'time':time,
                            'time_formatted':time_formatted,
                          });

                          var collection = FirebaseFirestore.instance.collection('Conversations');
                          collection
                              .doc(widget.conversationId) // <-- Doc ID where data should be updated.
                              .update({
                                'displayMessage' : _editingController.text,
                                'time':time,
                                'time_formatted':time_formatted,
                              }) // <-- Nested value
                              .catchError((error) => print('Update failed: $error'));

                          _editingController.text="";
                          _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeOut);
                        }
                      },
                      child: Icon(Icons.arrow_forward),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(CircleBorder()),
                        backgroundColor: MaterialStateProperty.all(Colors.blue), // <-- Button color),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}
