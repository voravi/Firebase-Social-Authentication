import 'package:flutter/material.dart';

void openSnackBar(BuildContext context, String snackMessage, Color color) {
  SnackBar snackBar = SnackBar(
    backgroundColor: color,
    content: Text(snackMessage),
    action: SnackBarAction(
      label: "OK",
      textColor: Colors.white,
      onPressed: () {},
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
