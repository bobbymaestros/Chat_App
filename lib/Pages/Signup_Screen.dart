import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Pages/ChangeProfile_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Helpers/UiHelper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();

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
    String confirmpassword = confirmpasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmpassword.isEmpty) {
      UiHelper.showAlertDialog(
          context, "Incomplete Data", "Please All the fields");
    } else if (password != confirmpassword) {
      UiHelper.showAlertDialog(context, "Password Mismatch",
          "The Passwords You Entered Do Not Match!!");
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;
    UiHelper.showLoadingDialog(context, "Creating new account");
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UiHelper.showAlertDialog(context, "An Error Occurred", ex.message!);
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: "",
      );
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        _message("User created", Colors.green);
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return CompleteProfile(
                userModel: newUser, firebasseUser: credential!.user!);
          },
        ));
      });
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
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.alternate_email_sharp),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              SizedBox(height: 10),
              TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_open_sharp),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)))),
              SizedBox(height: 10),
              TextField(
                  controller: confirmpasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_open_sharp),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)))),
              SizedBox(height: 20),
              CupertinoButton(
                child: Text('Sign Up',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  checkValues();
                },
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  "Have already an account?",
                  style: TextStyle(fontSize: 16),
                ),
                CupertinoButton(
                  child: Text('Log In', style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    Navigator.pop(context);
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
