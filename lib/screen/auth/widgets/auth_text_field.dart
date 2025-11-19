import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool obscureText; // si password itu, yg bulet" itu
  final Widget? suffixIcon;
  final TextInputType? keyboardType; // yg ada @ sama angka -> password and email
  final String? Function(String?)? validator; // utk error yang di atas text field nya

  const AuthTextField({super.key, required this.controller, required this.label, this.icon, required this.obscureText, this.suffixIcon, this.keyboardType, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }
}