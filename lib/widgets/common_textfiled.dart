import 'package:flutter/material.dart';

class CommonTextFiled extends StatelessWidget {
  final TextEditingController controller;
  bool isEnable = false;
  bool isVisible = false;
  String? labelText;
  CommonTextFiled({
    super.key,
    required this.controller,
    this.isEnable = false,
    this.isVisible = false,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isVisible,
      ignorePointers: isEnable,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
    );
  }
}
