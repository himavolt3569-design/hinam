import 'package:flutter/material.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        hintText: '98XXXXXXXX',
        prefixText: '+977 ',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Phone number is required';
        }

        if (value.trim().length != 10) {
          return 'Enter a valid phone number';
        }

        return null;
      },
    );
  }
}
