import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ssup/firebase_options.dart';
import 'package:ssup/pages/chatpage.dart';
import 'package:ssup/pages/forgotpassword.dart';
import 'package:ssup/pages/home.dart';
import 'package:ssup/pages/signin.dart';
import 'package:ssup/pages/signup.dart';
import 'package:ssup/services/auth.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: AuthMethods().getcurrenUser(),
          builder: (context, AsyncSnapshot<dynamic> snapshot){
        if(snapshot.hasData) {
          return Home();

        }else{
          return SignIn();
        }

      }
      ),
      
    );
  }
}
