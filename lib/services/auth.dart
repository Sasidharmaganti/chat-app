import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods{
  final FirebaseAuth auth= FirebaseAuth.instance;
  getcurrenUser() async{
    return await auth.currentUser;
  }
}