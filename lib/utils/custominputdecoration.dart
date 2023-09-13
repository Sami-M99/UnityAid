import 'package:flutter/material.dart';

class CustomInputDecoration extends StatelessWidget {
  final String hintText;

  const CustomInputDecoration({required this.hintText, key});

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      child:
          const SizedBox(), // Add an empty child widget to satisfy the InputDecorator requirement
    );
  }
}
