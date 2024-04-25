
import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField(
      {super.key,
        required this.controller,
        required this.isPassword,
        required this.labelTxt,
        required this.icon});

  final TextEditingController controller;
  final bool isPassword;
  final String labelTxt;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(5.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          prefixIcon: Icon(icon,color: Colors.black),
          filled: true,
          fillColor: Colors.black.withOpacity(0.2),
          labelText: labelTxt,
          labelStyle: TextStyle(color: Colors.black,
        ),
      ),
    )
    );
  }
}
