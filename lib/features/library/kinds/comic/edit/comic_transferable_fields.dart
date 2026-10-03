import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:flutter/material.dart';

/// Comic-entry transfer semantics stay typed until the generic transfer
/// dialog boundary. The adapter is deliberately created here, inside Comic.
final class ComicTransferableField {
  const ComicTransferableField({
    required this.key,
    required this.label,
    required this.icon,
    required this.type,
    required this.read,
    required this.write,
    this.scope = LibraryEntityScope.libraryEntry,
  });

  final String key;
  final String label;
  final IconData icon;
  final TransferableFieldType type;
  final LibraryEntityScope scope;
  final String? Function(ComicLibraryEntry item) read;
  final ComicLibraryEntry Function(ComicLibraryEntry item, String? value) write;

  TransferableField toTransferableField() {
    return TransferableField.typed<ComicLibraryEntry>(
      key: key,
      label: label,
      icon: icon,
      type: type,
      scope: scope,
      decode: (value) => value as ComicLibraryEntry,
      read: read,
      write: write,
    );
  }
}

final comicTransferableFields = <ComicTransferableField>[
  ComicTransferableField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.grade,
    write: (item, value) =>
        item.copyWith(personal: item.personal.copyWith(grade: value)),
  ),
  ComicTransferableField(
    key: 'rawOrSlabbed',
    label: 'Raw / Slabbed',
    icon: Icons.layers_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.details.rawOrSlabbed,
    write: (item, value) => item.copyWith(
        personal: item.personal.copyWith(
      details: item.personal.details.copyWith(rawOrSlabbed: value),
    )),
  ),
  ComicTransferableField(
    key: 'gradingCompany',
    label: 'Grading company',
    icon: Icons.verified_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.details.gradingCompany,
    write: (item, value) => item.copyWith(
        personal: item.personal.copyWith(
      details: item.personal.details.copyWith(gradingCompany: value),
    )),
  ),
  ComicTransferableField(
    key: 'graderNotes',
    label: 'Grader notes',
    icon: Icons.note_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.details.graderNotes,
    write: (item, value) => item.copyWith(
        personal: item.personal.copyWith(
      details: item.personal.details.copyWith(graderNotes: value),
    )),
  ),
  ComicTransferableField(
    key: 'signedBy',
    label: 'Signed by',
    icon: Icons.draw_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.details.signedBy,
    write: (item, value) => item.copyWith(
        personal: item.personal.copyWith(
      details: item.personal.details.copyWith(signedBy: value),
    )),
  ),
  ComicTransferableField(
    key: 'keyReason',
    label: 'Key reason',
    icon: Icons.vpn_key_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.details.keyReason,
    write: (item, value) => item.copyWith(
        personal: item.personal.copyWith(
      details: item.personal.details.copyWith(keyReason: value),
    )),
  ),
  ComicTransferableField(
    key: 'keyComic',
    label: 'Key issue',
    icon: Icons.vpn_key,
    type: TransferableFieldType.boolean,
    read: (item) => item.personal.details.keyComic ? 'true' : null,
    write: (item, value) => item.copyWith(
        personal: item.personal.copyWith(
      details: item.personal.details.copyWith(keyComic: value == 'true'),
    )),
  ),
  ComicTransferableField(
    key: 'coverPriceCents',
    label: 'Cover price',
    icon: Icons.price_check,
    type: TransferableFieldType.integer,
    scope: LibraryEntityScope.libraryEntry,
    read: (item) => item.personal.details.coverPriceCents?.toString(),
    write: (item, value) => item.copyWith(
        personal: item.personal.copyWith(
      details: item.personal.details.copyWith(
        coverPriceCents: value != null ? int.tryParse(value) : null,
      ),
    )),
  ),
];

final comicTransferableFieldDefinitions = [
  for (final field in comicTransferableFields) field.toTransferableField(),
];
