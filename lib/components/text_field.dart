import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final IconData prefixIcon;

  const MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      required this.prefixIcon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        prefixIcon: Icon(prefixIcon),
        fillColor: Colors.white,
        filled: true,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),
    );
  }
}
