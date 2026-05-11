import 'package:flutter/material.dart';

class MediaRatingField extends StatelessWidget {
  const MediaRatingField({
    super.key,
    required this.controller,
    this.label = 'Rating',
    this.maxRating = 10,
  });

  final TextEditingController controller;
  final String label;
  final int maxRating;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        helperText: '0-$maxRating',
        border: const OutlineInputBorder(),
      ),
    );
  }
}
