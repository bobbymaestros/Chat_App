import 'dart:io';

import 'package:chat_app/Helpers/UiHelper.dart';
import 'package:chat_app/Pages/Home_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../Models/UserModel.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebasseUser;

  const CompleteProfile(
      {super.key, required this.userModel, required this.firebasseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  void _message(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
    ));
  }

  File? imageFile;
  TextEditingController fullnameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickerFile = await ImagePicker().pickImage(source: source);

    if (pickerFile != null) {
      cropImage(pickerFile);
    }
  }

  void cropImage(XFile file) async {
    // File? croppedImage = (await ImageCropper().cropImage(
    //     sourcePath: file.path,
    //     aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    //     compressQuality: 20)) as File?;
    // if (croppedImage != null) {
    //   setState(() {
    //     imageFile = croppedImage;
    //   });
    // }
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      compressQuality: 10,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      setState(() {
        imageFile = File(croppedFile.path);
      });
    }
  }

  void showPhotoOption() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Upload Profile Picture'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
                leading: Icon(CupertinoIcons.photo),
                title: Text('Select From Gallery'),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
                leading: Icon(Icons.camera_alt_outlined),
                title: Text('Take a Photo'),
              )
            ]),
          );
        });
  }

  void checkValues() {
    String fullname = fullnameController.text.trim();

    if (fullname == "" || imageFile == "") {
      UiHelper.showAlertDialog(context, "Incomplete Data",
          "Please fill all the fields and profile picture");
    } else {
      _message('Uploading Data....', Colors.blueAccent);
      uploadData();
    }
  }

  void uploadData() async {
    UiHelper.showLoadingDialog(context, "Uploading Image");

    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepicture")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullname = fullnameController.text.trim();

    widget.userModel.fullname = fullname;
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      _message('Data Uploaded!!!', Colors.green);
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return HomeScreen(
              userModel: widget.userModel, firebaseUser: widget.firebasseUser);
        },
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('Complete Profile')),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: ListView(children: [
          SizedBox(height: 20),
          CupertinoButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              showPhotoOption();
            },
            child: CircleAvatar(
              radius: 60,
              backgroundImage:
                  (imageFile != null) ? FileImage(imageFile!) : null,
              child: (imageFile == null)
                  ? Icon(
                      Icons.person,
                      size: 60,
                    )
                  : null,
            ),
          ),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(labelText: 'Fullname'),
            controller: fullnameController,
          ),
          SizedBox(height: 20),
          CupertinoButton(
            child: Text('Submit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            color: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              checkValues();
            },
          )
        ]),
      )),
    );
  }
}
