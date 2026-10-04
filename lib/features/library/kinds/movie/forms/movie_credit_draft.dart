import 'package:flutter/material.dart';

enum MovieCreditKind { cast, crew }

@immutable
class MovieCreditInput {
  const MovieCreditInput({
    required this.name,
    this.role,
    this.sourceType = 'provider',
  });

  final String name;
  final String? role;
  final String sourceType;
}

class EditableMovieCredit {
  EditableMovieCredit({
    required this.nameController,
    required this.roleController,
    this.sourceType = 'custom',
  });

  factory EditableMovieCredit.custom({
    String name = '',
    String role = '',
    String sourceType = 'custom',
  }) =>
      EditableMovieCredit(
        nameController: TextEditingController(text: name),
        roleController: TextEditingController(text: role),
        sourceType: sourceType,
      );

  factory EditableMovieCredit.fromInput(MovieCreditInput input) =>
      EditableMovieCredit(
        nameController: TextEditingController(text: input.name),
        roleController: TextEditingController(text: input.role ?? ''),
        sourceType: input.sourceType,
      );

  final TextEditingController nameController;
  final TextEditingController roleController;
  final String sourceType;

  MovieCreditInput toInput() => MovieCreditInput(
        name: nameController.text.trim(),
        role: roleController.text.trim().isEmpty
            ? null
            : roleController.text.trim(),
        sourceType: sourceType,
      );

  void dispose() {
    nameController.dispose();
    roleController.dispose();
  }
}

const _castRoleTags = <String>{
  'actor',
  'voice',
  'voice actor',
  'guest star',
  'cameo',
  'narrator',
};

bool isMovieCastRole(String? role) {
  final normalized = role?.trim().toLowerCase() ?? '';
  if (normalized.isEmpty) return true;
  return _castRoleTags.any(normalized.contains);
}

List<EditableMovieCredit> splitMovieCredits(
  List<MovieCreditInput> credits, {
  required MovieCreditKind kind,
}) =>
    [
      for (final credit in credits)
        if ((kind == MovieCreditKind.cast && isMovieCastRole(credit.role)) ||
            (kind == MovieCreditKind.crew && !isMovieCastRole(credit.role)))
          EditableMovieCredit.fromInput(credit),
    ];
