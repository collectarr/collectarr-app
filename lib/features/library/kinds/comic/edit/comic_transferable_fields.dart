import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/legacy/comic_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:flutter/material.dart';

/// Comic-owned transfer semantics stay typed until the old generic transfer
/// dialog boundary. The adapter is deliberately created here, inside Comic.
final class ComicTransferableField {
  const ComicTransferableField({
    required this.key,
    required this.label,
    required this.icon,
    required this.type,
    required this.read,
    required this.write,
    this.scope = LibraryEditScope.all,
  });

  final String key;
  final String label;
  final IconData icon;
  final TransferableFieldType type;
  final LibraryEditScope scope;
  final String? Function(ComicOwnedItem item) read;
  final ComicOwnedItem Function(ComicOwnedItem item, String? value) write;

  TransferableField toLegacyField() {
    return TransferableField(
      key: key,
      label: label,
      icon: icon,
      type: type,
      scope: scope,
      read: (legacy) {
        final typed = ComicOwnedItemLegacyAdapter.tryFromLegacy(legacy);
        return typed == null ? null : read(typed);
      },
      write: (legacy, value) {
        final typed = ComicOwnedItemLegacyAdapter.tryFromLegacy(legacy);
        return typed == null
            ? legacy
            : ComicOwnedItemLegacyAdapter.toLegacy(write(typed, value));
      },
    );
  }
}

final comicTransferableFields = <ComicTransferableField>[
  ComicTransferableField(
    key: 'rawOrSlabbed',
    label: 'Raw / Slabbed',
    icon: Icons.layers_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.details.rawOrSlabbed,
    write: (item, value) => item.copyWith(
      details: item.details.copyWith(rawOrSlabbed: value),
    ),
  ),
  ComicTransferableField(
    key: 'gradingCompany',
    label: 'Grading company',
    icon: Icons.verified_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.details.gradingCompany,
    write: (item, value) => item.copyWith(
      details: item.details.copyWith(gradingCompany: value),
    ),
  ),
  ComicTransferableField(
    key: 'graderNotes',
    label: 'Grader notes',
    icon: Icons.note_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.details.graderNotes,
    write: (item, value) => item.copyWith(
      details: item.details.copyWith(graderNotes: value),
    ),
  ),
  ComicTransferableField(
    key: 'signedBy',
    label: 'Signed by',
    icon: Icons.draw_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.details.signedBy,
    write: (item, value) => item.copyWith(
      details: item.details.copyWith(signedBy: value),
    ),
  ),
  ComicTransferableField(
    key: 'keyReason',
    label: 'Key reason',
    icon: Icons.vpn_key_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.details.keyReason,
    write: (item, value) => item.copyWith(
      details: item.details.copyWith(keyReason: value),
    ),
  ),
  ComicTransferableField(
    key: 'keyComic',
    label: 'Key issue',
    icon: Icons.vpn_key,
    type: TransferableFieldType.boolean,
    read: (item) => item.details.keyComic ? 'true' : null,
    write: (item, value) => item.copyWith(
      details: item.details.copyWith(keyComic: value == 'true'),
    ),
  ),
  ComicTransferableField(
    key: 'coverPriceCents',
    label: 'Cover price',
    icon: Icons.price_check,
    type: TransferableFieldType.integer,
    scope: LibraryEditScope.release,
    read: (item) => item.details.coverPriceCents?.toString(),
    write: (item, value) => item.copyWith(
      details: item.details.copyWith(
        coverPriceCents: value != null ? int.tryParse(value) : null,
      ),
    ),
  ),
];

final legacyComicTransferableFields = [
  for (final field in comicTransferableFields) field.toLegacyField(),
];
