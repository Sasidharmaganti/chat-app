import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ssup/pages/forgotpassword.dart';
import 'package:ssup/pages/signup.dart';
import 'package:ssup/services/database.dart';
import 'package:ssup/services/shared_pref.dart';

import 'home.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  String email = "";
  String password = "";
  String pic = "", name = "", username = "", id = "";
  TextEditingController usermailcontroller = TextEditingController();
  TextEditingController userpasswordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  userLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      QuerySnapshot querySnapshot= await DatabaseMethods().getUserbyemail(email);
      name="${querySnapshot.docs[0]["Name"]}";
      username="${querySnapshot.docs[0]["username"]}";
      pic="${querySnapshot.docs[0]["Photo"]}";
      id= querySnapshot.docs[0].id;


      await SharedPreferenceHelper().saveUserDisplayName(name);
      await SharedPreferenceHelper().saveUserName(username);
      await SharedPreferenceHelper().saveUserId(id);
      await SharedPreferenceHelper().saveUserPic(pic);

      Navigator.pushReplacement(
          context, MaterialPageRoute(
          builder: (context) => Home()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "No user found for that email",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Wrong password provided by user",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        );
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
                    bottom: Radius.elliptical(MediaQuery.of(context).size.width, 105),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 70.0),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        "SignIn",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Login to your account",
                        style: TextStyle(
                          color: Color(0xFFbbb0ff),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Form(
                            key: _formkey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Email",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: Colors.black38),
                                  ),
                                  child: TextFormField(
                                    controller: usermailcontroller,
                                    validator: (value) {
                                      if(value==null || value.isEmpty){
                                        return 'Please enter the E-mail';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: Icon(Icons.mail_outline, color: Color(0xFF7f30fe)),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "Password",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: Colors.black38),
                                  ),
                                  child: TextFormField(
                                    controller: userpasswordcontroller,
                                    validator: (value) {
                                      if(value==null || value.isEmpty){
                                        return 'Please enter the password';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: Icon(Icons.password, color: Color(0xFF7f30fe)),
                                    ),
                                    obscureText: true,
                                  ),
                                ),
                                SizedBox(height: 10),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context)=>ForgotPassword()));
                                  },
                                  child: Container(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 50),
                                GestureDetector(
                                  onTap: () async {
                                    if (_formkey.currentState!.validate()) {
                                      setState(() {
                                        email = usermailcontroller.text;
                                        password = userpasswordcontroller.text;
                                        _isLoading = true; // Show the loading spinner before login
                                      });

                                      try {
                                        await userLogin();
                                      } catch (e) {
                                        // Handle any errors here
                                      } finally {
                                        setState(() {
                                          _isLoading = false; // Hide the loading spinner after login
                                        });
                                      }
                                    }
                                  },
                                  child: _isLoading
                                      ? CircularProgressIndicator()
                                      : Center(
                                        child: Container(
                                          width: 150,
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
                                              "SignIn",
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

                              ],
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
                          "Don't have an account ?",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUp()));
                          },
                          child: Text(
                            " Sign Up Now !",
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
