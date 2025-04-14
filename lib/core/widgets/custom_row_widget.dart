import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:smart_diet/core/widgets/custom_small_text_form_field.dart';

class CustomRow extends StatelessWidget {
  final String hintText1;
  final String hintText2;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final TextEditingController controller2;
  const CustomRow({
    super.key,
    required this.hintText1,
    required this.hintText2,
    this.keyboardType, required this.controller, required this.controller2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: CustomSmallTextFormField(
          controller: controller,
          hintText: hintText1,
          keyboardType: keyboardType,
        )),
        const Gap(10),
        Expanded(
            child: CustomSmallTextFormField(
          controller: controller2,
          hintText: hintText2,
          keyboardType: keyboardType,
        )),
      ],
    );
  }
}
