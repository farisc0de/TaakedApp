import 'package:flutter/material.dart';

showAlertDialog(
    title, message, BuildContext context, void Function()? onPressed) {
  // Create button
  Widget okButton = TextButton(
    child: const Text("OK"),
    onPressed: onPressed,
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
