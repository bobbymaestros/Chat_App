import 'package:chat_app/Helpers/UiHelper.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Pages/Signup_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Home_Screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void _message(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      UiHelper.showAlertDialog(
          context, "Incomplete Data", "Please All the fields");
    } else {
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? credential;
    UiHelper.showLoadingDialog(context, "Logging In...");

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UiHelper.showAlertDialog(
          context, "An Error Occured", ex.message.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      DocumentSnapshot userdata =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userdata.data() as Map<String, dynamic>);

      _message('Log In Successfully', Colors.green);
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return HomeScreen(
              userModel: userModel, firebaseUser: credential!.user!);
        },
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Center(
          child: SingleChildScrollView(
              child: Column(
            children: [
              Image.asset("assets/images/LoginImg.png"),
              SizedBox(height: 15),
              Text(
                'Chat App',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: Icon(Icons.alternate_email_sharp)),
              ),
              SizedBox(height: 20),
              TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Icon(Icons.lock_open_sharp))),
              SizedBox(height: 20),
              CupertinoButton(
                child: Text('Log In',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  checkValues();
                },
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(fontSize: 16),
                ),
                CupertinoButton(
                  child: Text('Sign Up', style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return SignupScreen();
                    }));
                  },
                )
              ]),
            ],
          )),
        ),
      )),
    );
  }
}
