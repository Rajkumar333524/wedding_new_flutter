import 'package:flutter/material.dart';

class KeyboardFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final FocusNode current;
  final FocusNode? next;
  final bool isLast;

  const KeyboardFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.current,
    this.next,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: current,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      onSubmitted: (_) {
        if (!isLast && next != null) {
          FocusScope.of(context).requestFocus(next);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.85),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
