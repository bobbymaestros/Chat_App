import 'package:chat_app/Pages/Login_Screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      body: SafeArea(
          child: Container(
        // alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset("assets/images/peakpx-removebg-preview.png"),
          Text("Let's Have\nChat Together!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25)),
          SizedBox(height: 15),
          Text(
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
              'Mobile Messaging is rapidly becoming\nthe primary way users engages socially\non mobile'),
          SizedBox(height: 50),
          CupertinoButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return LoginScreen();
              },));
            },
            child: CircleAvatar(
                radius: 35,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Icon(
                  Icons.arrow_right_alt_sharp,size: 25,
                  color: Colors.white,
                )),
          ),
        ]),
      ),
      ),
    );
  }
}
