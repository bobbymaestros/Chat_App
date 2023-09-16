import 'package:flutter/material.dart';

class UiHelper {
  static void showLoadingDialog(BuildContext context, String title) {
    AlertDialog loadingDialog = AlertDialog(
      content: Container(
        padding: EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(),
          SizedBox(
            height: 30,
          ),
          Text(title),
        ]),
      ),
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return loadingDialog;
      },
    );
  }

  static void showAlertDialog(
      BuildContext context, String title, String content) {
    AlertDialog alertDialog = AlertDialog(
      content: Text(content),
      title: Text(title),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("OK"),
        )
      ],
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return alertDialog;
      },
    );
  }
}
