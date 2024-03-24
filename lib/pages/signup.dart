import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:ssup/pages/signin.dart';
import 'package:ssup/services/database.dart';
import 'package:ssup/services/shared_pref.dart';
import 'home.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", name = "", comfirmPassword = "";
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController confirmPasswordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  registration() async {
    if (password != null && password == comfirmPassword) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: email, password: password);

        String Id = randomAlphaNumeric(10);
        String user= mailcontroller.text.replaceAll("@gmail.com", "");
        String updateusername= user.replaceFirst(user[0], user[0].toUpperCase());
        String firstletter = user.substring(0,1).toUpperCase();

        Map<String, dynamic> userInformMap = {
          "Name": namecontroller.text,
          "E-mail": mailcontroller.text,
          "username": updateusername.toUpperCase(),
          "SearchKey": firstletter,
          "Photo":
          "https://www.google.com/imgres?imgurl=https%3A%2F%2Fimg.freepik.com%2Ffree-vector%2Fbusinessman-character-avatar-isolated_24877-60111.jpg%3Fsize%3D338%26ext%3Djpg%26ga%3DGA1.1.1395880969.1710201600%26semt%3Dais&tbnid=5r2gsiMQhMPg3M&vet=12ahUKEwjV_qLSlPSEAxVyzTgGHe5MA5kQMygUegUIARCfAQ..i&imgrefurl=https%3A%2F%2Fwww.freepik.com%2Ffree-photos-vectors%2Fuser-profile-pic&docid=yBaB5iOH6jaBQM&w=338&h=338&q=user%20photo&ved=2ahUKEwjV_qLSlPSEAxVyzTgGHe5MA5kQMygUegUIARCfAQ",
          "Id": Id,
        };
        await DatabaseMethods().addUserDetails(userInformMap, Id);
        await SharedPreferenceHelper().saveUserId(Id);
        await SharedPreferenceHelper()
            .saveUserDisplayName(namecontroller.text);
        await SharedPreferenceHelper().saveUserEmail(mailcontroller.text);
        await SharedPreferenceHelper().saveUserPic(
            "https://www.google.com/imgres?imgurl=https%3A%2F%2Fimg.freepik.com%2Ffree-vector%2Fbusinessman-character-avatar-isolated_24877-60111.jpg%3Fsize%3D338%26ext%3Djpg%26ga%3DGA1.1.1395880969.1710201600%26semt%3Dais&tbnid=5r2gsiMQhMPg3M&vet=12ahUKEwjV_qLSlPSEAxVyzTgGHe5MA5kQMygUegUIARCfAQ..i&imgrefurl=https%3A%2F%2Fwww.freepik.com%2Ffree-photos-vectors%2Fuser-profile-pic&docid=yBaB5iOH6jaBQM&w=338&h=338&q=user%20photo&ved=2ahUKEwjV_qLSlPSEAxVyzTgGHe5MA5kQMygUegUIARCfAQ");
        await SharedPreferenceHelper()
            .saveUserName(mailcontroller.text.replaceAll("@gmail.com", "").toUpperCase()
        );

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text("Registered Successfully",
                style: TextStyle(fontSize: 20))));
    Navigator.pushReplacement(context,
    MaterialPageRoute(builder: (context) => Home()));
    } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text("Password provided is too weak",
    style: TextStyle(fontSize: 18))));
    } else if (e.code == 'email-already-in-use') {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text("Account already exists",
    style: TextStyle(fontSize: 18))));
    }
    }
  }
  }
bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 4,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7f30fe), Color(0xFF6380fb)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(
                          MediaQuery.of(context).size.width, 105),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 70.0),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          "SignUp",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          "Create a new account",
                          style: TextStyle(
                            color: Color(0xFFbbb0ff),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        margin:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 30, horizontal: 20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Form(
                              key: _formkey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "Name",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500)
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.only(left:10),
                                      decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black38)),
                                      child:TextFormField(
                                        controller: namecontroller,
                                        validator: (value){
                                          if(value==null || value.isEmpty){
                                            return 'Please Enter Name';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            prefixIcon: Icon(
                                                Icons.person_outline,
                                                color: Color(0xFF7f30fe)
                                            )
                                        ),

                                      )),
                                  SizedBox(height: 10),
                                  Text(
                                      "Email",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500)
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.only(left:10),
                                      decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black38)),
                                      child:TextFormField(
                                        controller: mailcontroller,
                                        validator: (value){
                                          if(value==null || value.isEmpty){
                                            return 'Please Enter E-mail';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            prefixIcon: Icon(Icons.mail_outline,
                                                color: Color(0xFF7f30fe)
                                            )
                                        ),

                                      )),
                                  SizedBox(height: 20),
                                  Text(
                                      "Password",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500)
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.only(left:10),
                                    decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black38)),
                                    child:TextFormField(
                                      controller: passwordcontroller,
                                      validator: (value){
                                        if(value==null || value.isEmpty){
                                          return 'Please Enter Password';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          prefixIcon: Icon(Icons.password,
                                              color: Color(0xFF7f30fe)
                                          )),
                                      obscureText: true,

                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                      "Confirm Password",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500)
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.only(left:10),
                                    decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black38)),
                                    child:TextFormField(
                                      controller: confirmPasswordcontroller,
                                      validator: (value){
                                        if(value==null || value.isEmpty){
                                          return 'Please Enter Confirm Password';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          prefixIcon: Icon(Icons.password,
                                              color: Color(0xFF7f30fe)
                                          )),
                                      obscureText: true,

                                    ),
                                  ),

                                ],),
                            ),
                          ),

                        ),
                      ),
                      SizedBox(height:20),
                      GestureDetector(
                        onTap: () async {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              email = mailcontroller.text;
                              name = namecontroller.text;
                              password = passwordcontroller.text;
                              comfirmPassword = confirmPasswordcontroller.text;
                              _isLoading = true; // Show the loading spinner before registration
                            });

                            await registration();

                            setState(() {
                              _isLoading = false; // Hide the loading spinner after registration
                            });
                          }
                        },
                        child: _isLoading
                            ? CircularProgressIndicator()
                            : Center(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            width: MediaQuery.of(context).size.width,
                            child: Material(
                              elevation: 5,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Color(0xff6300fb),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "SignUp",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account ?",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> SignIn()));
                            },
                            child: Text(
                              " Login",
                              style: TextStyle(
                                color: Color(0xff6300fb),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),


                    ],
                  ),
                )

              ],)
        ),
      ),
    );
  }
}
