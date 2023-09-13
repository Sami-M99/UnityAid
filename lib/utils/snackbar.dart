import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
  final scaffoldContext = ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
  // Use the scaffoldContext for further actions if needed
}
