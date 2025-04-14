import 'package:flutter/material.dart';

class CustomSmallTextFormField extends StatelessWidget {
  final String hintText;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  const CustomSmallTextFormField({
    super.key,
    required this.hintText,
    this.keyboardType, required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 175,
      height: 50,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade300,
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          hintText: hintText,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
    );
  }
}
