import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata_children.dart';
import 'package:flutter/material.dart';

enum AnimeCreditKind { cast, crew }

/// Typed editable input for Anime cast and crew credits.
@immutable
class AnimeCreditInput {
  const AnimeCreditInput({
    required this.name,
    this.role,
    this.source,
    this.originalIndex,
  });

  final String name;
  final String? role;
  final AnimePersonMetadata? source;
  final int? originalIndex;
}

const _videoCastRoleTags = <String>{
  'actor',
  'voice',
  'voice actor',
  'guest star',
  'cameo',
  'narrator',
};

class EditableAnimeCredit {
  EditableAnimeCredit({
    required this.nameController,
    required this.roleController,
    required this.source,
    required this.originalIndex,
  });

  factory EditableAnimeCredit.custom({
    String name = '',
    String role = '',
  }) =>
      EditableAnimeCredit(
        nameController: TextEditingController(text: name),
        roleController: TextEditingController(text: role),
        source: null,
        originalIndex: null,
      );

  factory EditableAnimeCredit.fromInput(AnimeCreditInput input) =>
      EditableAnimeCredit(
        nameController: TextEditingController(text: input.name),
        roleController: TextEditingController(text: input.role ?? ''),
        source: input.source,
        originalIndex: input.originalIndex,
      );

  final TextEditingController nameController;
  final TextEditingController roleController;
  final AnimePersonMetadata? source;
  final int? originalIndex;

  AnimeCreditInput toInput() => AnimeCreditInput(
        name: nameController.text.trim(),
        role: roleController.text.trim().isEmpty
            ? null
            : roleController.text.trim(),
        source: source,
        originalIndex: originalIndex,
      );

  AnimePersonMetadata toMetadata({int? newSequence}) {
    final input = toInput();
    final original = input.source;
    final nameChanged = original != null && input.name != original.name;
    final roleChanged = original != null && input.role != original.role;
    return AnimePersonMetadata(
      name: input.name,
      id: original?.id,
      personId: original?.personId,
      artistId: original?.artistId,
      role: input.role,
      roleId: roleChanged ? null : original?.roleId,
      sequence: original?.sequence ?? newSequence,
      creditedName: original != null && original.creditedName == original.name
          ? input.name
          : original?.creditedName,
      joinPhrase: original?.joinPhrase,
      imageUrl: original?.imageUrl,
      sortName: nameChanged ? null : original?.sortName,
      instrument: original?.instrument,
      stringValue: original?.stringValue == true && input.role == null,
    );
  }

  void dispose() {
    nameController.dispose();
    roleController.dispose();
  }
}

bool isAnimeCastRole(String? role) {
  final normalized = role?.trim().toLowerCase() ?? '';
  if (normalized.isEmpty) return true;
  return _videoCastRoleTags.any(normalized.contains);
}

List<EditableAnimeCredit> splitAnimeCredits(
  List<AnimeCreditInput> creators, {
  required AnimeCreditKind kind,
}) =>
    [
      for (var index = 0; index < creators.length; index++)
        if ((kind == AnimeCreditKind.cast &&
                isAnimeCastRole(creators[index].role)) ||
            (kind == AnimeCreditKind.crew &&
                !isAnimeCastRole(creators[index].role)))
          EditableAnimeCredit.fromInput(
            AnimeCreditInput(
              name: creators[index].name,
              role: creators[index].role,
              source: creators[index].source,
              originalIndex: creators[index].originalIndex ?? index,
            ),
          ),
    ];
