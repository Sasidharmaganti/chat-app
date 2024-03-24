import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:ssup/services/database.dart';
import 'package:ssup/services/shared_pref.dart';

import 'home.dart';

class ChatPage extends StatefulWidget {
  String name, profileurl, username;
  ChatPage({required this.name, required this.profileurl, required this.username});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messagecontroller = new TextEditingController();
  String? myUserName, myProfilePic, myName, myEmail, messageId, chatRoomId;
  Stream? messageStream;

  gethesharedpref()async{
    myUserName= await SharedPreferenceHelper().getUserName();
    myProfilePic= await SharedPreferenceHelper().getUserPic();
    myName= await SharedPreferenceHelper().getDisplayName();

    chatRoomId = getChatRoomIdbyUsername(widget.username, myUserName!);
    myEmail= await SharedPreferenceHelper().getUserEmail();
    setState(() {

    });
  }

  ontheLoad()async{
    await gethesharedpref();
    await getAndSetMessages();
    setState(() {

    });
  }
  
@override
  void initState(){
    super.initState();
    ontheLoad();
  }


  getChatRoomIdbyUsername(String a, String b){
    if(a.substring(0,1).codeUnitAt(0)> b.substring(0,1).codeUnitAt(0)){
      return "$b\ $a";
    }
    else{
      return "$a\ $b";
    }
  }

  Widget chatMessageTile(String message, bool sendByMe){
    return Row(
      mainAxisAlignment:sendByMe?MainAxisAlignment.end: MainAxisAlignment.start,
      children: [
        Flexible(
            child:
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical:4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft:Radius.circular(24),
                      bottomRight:sendByMe?Radius.circular(0):Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomLeft:sendByMe?Radius.circular(24):Radius.circular(0),
                  ),
                color: sendByMe?Color.fromARGB(255,234,236,240): Color.fromARGB(255,211,228,243),
              ),
              child: Text(message,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            )
        ),
      ],
    );
  }

  Widget chatMessage(){
    return StreamBuilder(
        stream: messageStream,
        builder: (context, AsyncSnapshot snapshot){
          return snapshot.hasData? ListView.builder(
              padding: EdgeInsets.only(bottom: 90, top:130),
              itemCount: snapshot.data.docs.length,
              reverse:true,
              itemBuilder:(context, index){
                DocumentSnapshot ds= snapshot.data.docs[index];
                return chatMessageTile(ds["message"],myUserName==ds["sendBy"]);
              }):Center(
            child: CircularProgressIndicator(),
          );
        });
  }
  addMessage(bool sendClicked){
    if(messagecontroller.text!=""){
      String message= messagecontroller.text;
      messagecontroller.text="";

      DateTime now = DateTime.now();
      String formattedDate= DateFormat('h:mma').format(now);
      Map<String, dynamic> messageInfoMap={
        "message": message,
        "sendBy": myUserName,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": myProfilePic,
      };

      messageId ??= randomAlphaNumeric(10);

      DatabaseMethods()
          .addMessage(chatRoomId!, messageId!, messageInfoMap)
          .then((value){
        Map<String, dynamic> lastMessageInfoMap={
          "LastMessage": message,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSendBy": myUserName,
        };
        DatabaseMethods().updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
        if(sendClicked){
          messageId= null;
        }
      });
    }
  }

  getAndSetMessages()async{
  messageStream = await DatabaseMethods()
      .getChatRoomMessages(chatRoomId);
  setState(() {

  });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF553370),
      body:
        Container(
            margin: EdgeInsets.only(top: 60),
            child:
            Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 50),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 1.12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: chatMessage(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                          );
                        },
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xffc199cd),
                        ),
                      ),
                      Spacer(), // Pushes the name text to the center
                      Text(
                        widget.name,
                        style: TextStyle(
                          color: Color(0xffc199cd),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(), // Pushes any following widgets to the end
                    ],
                  ),


                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: messagecontroller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type a message",
                            hintStyle: TextStyle(color: Colors.black45),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                addMessage(true);
                              },
                              child: Icon(Icons.send_rounded),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

          )


    );
  }
}
