import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true,
    this.prefix,
    this.suffix,
    this.hintText,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool enabled;
  final Widget? prefix;
  final Widget? suffix;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefix,
        suffixIcon: suffix,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
    );
  }
}
