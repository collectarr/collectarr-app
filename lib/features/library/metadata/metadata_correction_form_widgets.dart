import 'package:flutter/material.dart';

class MetadataCorrectionTextField extends StatelessWidget {
  const MetadataCorrectionTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
    this.isDense = false,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final bool isDense;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        isDense: isDense,
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class MetadataCorrectionSectionLabel extends StatelessWidget {
  const MetadataCorrectionSectionLabel({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall,
    );
  }
}