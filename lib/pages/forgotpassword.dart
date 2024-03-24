import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ssup/pages/signup.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  String email="";
  final _formkey= GlobalKey<FormState>();

  TextEditingController usermailcontroller = new TextEditingController();

  resetPassword() async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            "Password Reset Email has been sent",
            style: TextStyle(fontSize: 18),)
          )
      );
    }on FirebaseAuthException catch(e){
      if(e.code=="user-not-found"){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(
              "No user found for that email",
              style: TextStyle(fontSize: 18),)
            )
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
                        "Password Recovery",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Enter your mail",
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

                                SizedBox(height: 50),
                                GestureDetector(
                                  onTap: () async {
                                    if (_formkey.currentState!.validate()) {
                                      setState(() {
                                        email = usermailcontroller.text;
                                        _isLoading = true; // Show the loading spinner before login
                                      });

                                      try {
                                        await resetPassword();
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
