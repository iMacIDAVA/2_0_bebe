import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final bool obscureText;
  const MyTextField(
      {super.key, required this.textEditingController, required this.hintText, required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(
        color: Color(0xff677294),
      ),
      minLines: 1,
      maxLines: 6,
      controller: textEditingController,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xff677294)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        fillColor: const Color(0xffF4F5FB),
        filled: true,
      ),
    );
  }
}
