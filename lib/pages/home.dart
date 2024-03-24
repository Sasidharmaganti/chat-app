import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ssup/pages/signin.dart';
import 'package:ssup/services/database.dart';
import 'package:ssup/services/shared_pref.dart';
import 'chatpage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {


  bool search = false;
  String? myName, myProfilePic, myUserName, myEmail;
  Stream? chatRoomStream;

  getthesharedpref()async{
    myName= await SharedPreferenceHelper().getDisplayName();
    myProfilePic= await SharedPreferenceHelper().getUserPic();
    myUserName= await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    setState(() {

    });
  }

  ontheLoad()async{
    await getthesharedpref();
    chatRoomStream = await DatabaseMethods().getChatRooms();
    setState(() {

    });
  }

  Widget ChatRoomList() {
    return StreamBuilder(
      stream: chatRoomStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              String lastMessage = ds["LastMessage"];
              return ChatRoomListTile(
                chatRoomId: ds.id,
                lastMessage: lastMessage,
                myUsername: myUserName!,
                time: ds["lastMessageSendTs"],
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
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

  var queryResultSet= [];
  var tempSearchStore=[];

  initiateSearch(value){
    if(value.length==0){
      setState(() {
        queryResultSet=[];
        tempSearchStore=[];
      });
    }
    setState(() {
      search=true;
    });
    var capitalizedValue = value.substring(0,1).toUpperCase()+ value.substring(1);
    if(queryResultSet.length==0 && value.length==1){
      DatabaseMethods().Search(value).then((QuerySnapshot docs){
        for(int i=0;i<docs.docs.length;++i){
          queryResultSet.add(docs.docs[i].data());
        }
      });
    }
    else{
      tempSearchStore=[];
      queryResultSet.forEach((element) {
        if(element['username'].startsWith(capitalizedValue)){
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF553370),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    search
                        ? Expanded(
                      child: TextField(
                        onChanged: (value) {
                          initiateSearch(value.toUpperCase());
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search User',
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                        : Text(
                      "ChatUp",
                      style: TextStyle(
                        color: Color(0xffc199cd),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        search = true;
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xff3a2144),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: search
                            ? GestureDetector(
                          onTap: () {
                            search = false;
                            setState(() {});
                          },
                          child: Icon(
                            Icons.close,
                            color: Color(0xffc199cd),
                          ),
                        )
                            : Icon(
                          Icons.search,
                          color: Color(0xffc199cd),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                height: search ? MediaQuery.of(context).size.height / 1.15 : MediaQuery.of(context).size.height / 1.10,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // search bar and other widgets
                    Expanded(
                      child: search
                          ? ListView(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        primary: false,
                        shrinkWrap: true,
                        children: tempSearchStore.map((element) {
                          return buildResultCard(element);
                        }).toList(),
                      )
                          : Expanded(
                        child: ChatRoomList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder:
                              (context)=> SignIn()
                          ));
                        },
                        child: Text('Logout'),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildResultCard(data){
    return GestureDetector(
      onTap: ()async {
        search=false;
        setState(() {

        });
        var chatRoomId= getChatRoomIdbyUsername(myUserName!, data["username"]);
        Map<String, dynamic> chatRoomInfoMap={
          "users": [myUserName, data["username"]],
        };
        await DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatPage(name: data["Name"],profileurl: data["Photo"],username: data["username"],)));

      },
      child: Container(

        margin: EdgeInsets.symmetric(vertical:8),
        child:
        Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(10),
          child:
          Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)
              ),
              child:
              Row(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset("images/boy.avif", height: 70, width: 70, fit: BoxFit.cover)
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data["Name"],
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(data["username"],
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 15
                        ),
                      ),

                    ],
                  )
                ],
              )
          ),
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername, time;

  ChatRoomListTile({required this.chatRoomId, required this.lastMessage,required this.myUsername, required this.time});


  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {

  String  name="", username="",id="";
  getthisUserInfo()async{
    username= widget.chatRoomId
        .replaceAll("_", "")
        .replaceAll(widget.myUsername, "");

    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username.toUpperCase());
    name="${querySnapshot.docs[0]["Name"]}";
    id="${querySnapshot.docs[0]["Id"]}";
    setState(() {

    });
  }


  @override
  void initState() {
    getthisUserInfo();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical:20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.asset(
              "images/boy.avif",
              height: 70,
              width: 70,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width:20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height:10),
              Text(username,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  )
              ),
              Container(
                width: MediaQuery.of(context).size.width/2.5,
                child: Text(
                    widget.lastMessage,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    )
                ),
              ),

            ],
          ),
          Spacer(),
          Text(
              widget.time,
              style: TextStyle(
                color: Colors.black45,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              )
          ),
        ],
      ),
    );
  }
}
