import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:flutter/material.dart';

enum TvCreditKind { cast, crew }

@immutable
class TvCreditInput {
  const TvCreditInput({
    required this.name,
    this.role,
    this.originalCredit,
  });

  final String name;
  final String? role;
  final TvPersonCredit? originalCredit;
}

const _videoCastRoleTags = <String>{
  'actor',
  'voice',
  'voice actor',
  'guest star',
  'cameo',
  'narrator',
};

class EditableTvCredit {
  EditableTvCredit({
    required this.nameController,
    required this.roleController,
    this.originalCredit,
  });

  factory EditableTvCredit.custom({
    String name = '',
    String role = '',
  }) =>
      EditableTvCredit(
        nameController: TextEditingController(text: name),
        roleController: TextEditingController(text: role),
      );

  factory EditableTvCredit.fromInput(TvCreditInput input) => EditableTvCredit(
        nameController: TextEditingController(text: input.name),
        roleController: TextEditingController(text: input.role ?? ''),
        originalCredit: input.originalCredit,
      );

  final TextEditingController nameController;
  final TextEditingController roleController;
  final TvPersonCredit? originalCredit;

  TvCreditInput toInput() => TvCreditInput(
        name: nameController.text.trim(),
        role: roleController.text.trim().isEmpty
            ? null
            : roleController.text.trim(),
        originalCredit: originalCredit,
      );

  void dispose() {
    nameController.dispose();
    roleController.dispose();
  }
}

bool isTvCastRole(String? role) {
  final normalized = role?.trim().toLowerCase() ?? '';
  if (normalized.isEmpty) return true;
  return _videoCastRoleTags.any(normalized.contains);
}

List<EditableTvCredit> splitTvCredits(
  List<TvCreditInput> creators, {
  required TvCreditKind kind,
}) =>
    [
      for (final creator in creators)
        if ((kind == TvCreditKind.cast && isTvCastRole(creator.role)) ||
            (kind == TvCreditKind.crew && !isTvCastRole(creator.role)))
          EditableTvCredit.fromInput(creator),
    ];
