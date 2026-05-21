import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/detail/generic_library_detail_page.dart';
import 'package:collectarr_app/features/library/inspector/generic_library_inspector_header.dart';
import 'package:collectarr_app/features/library/inspector/generic_library_inspector_sections.dart';
import 'package:collectarr_app/features/library/inspector/generic_metadata_correction_dialog.dart';
import 'package:collectarr_app/features/library/inspector/inspector_custom_fields_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_item_images_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenericLibraryInspector extends ConsumerWidget {
  const GenericLibraryInspector({
    super.key,
    required this.type,
    required this.entry,
    required this.ownedItem,
    required this.accent,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
    required this.onEdit,
    this.onFilterByValue,
    this.db,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry? entry;
  final OwnedItem? ownedItem;
  final Color accent;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final VoidCallback? onEdit;
  final ValueChanged<String>? onFilterByValue;
  final LocalDatabase? db;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = entry;
    if (selected == null) {
      return GenericEmptyInspector(type: type, accent: accent);
    }
    return Stack(
      children: [
        Positioned.fill(
          child: GenericInspectorBackdrop(entry: selected),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(color: Color(0xBA111111)),
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              GenericInspectorActionBar(
                type: type,
                entry: selected,
                onToggleOwned: selected.isOwned ? onRemoveOwned : onAddOwned,
                onToggleWishlist:
                    selected.isWishlisted ? onRemoveWishlist : onAddWishlist,
                onEdit: onEdit,
                onCorrectMetadata: type.supportedMetadataProviders.isNotEmpty
                    ? () => showGenericMetadataCorrectionDialog(
                          context: context,
                          ref: ref,
                          item: CatalogItem(
                            id: selected.id,
                            kind: type.workspace.kind,
                            title: selected.title,
                            itemNumber: selected.itemNumber,
                            publisher: selected.publisher,
                            releaseYear: selected.releaseYear,
                            barcode: selected.barcode,
                            variant: selected.variant,
                          ),
                          type: type,
                        )
                    : null,
                onOpenDetails: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GenericLibraryDetailPage(
                      type: type,
                      entry: selected,
                      ownedItem: ownedItem,
                      accent: accent,
                      onAddOwned: onAddOwned,
                      onRemoveOwned: onRemoveOwned,
                      onAddWishlist: onAddWishlist,
                      onRemoveWishlist: onRemoveWishlist,
                      onEdit: onEdit,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              GenericInspectorHero(
                type: type,
                entry: selected,
                ownedItem: ownedItem,
                accent: accent,
              ),
              const SizedBox(height: 10),
              GenericInspectorPrimaryActions(
                entry: selected,
                type: type,
                onAddOwned: onAddOwned,
                onRemoveOwned: onRemoveOwned,
                onAddWishlist: onAddWishlist,
                onRemoveWishlist: onRemoveWishlist,
                onEdit: onEdit,
              ),
              if (ownedItem != null &&
                  (type.conditions.isNotEmpty || type.grades.isNotEmpty)) ...[
                const SizedBox(height: 10),
                InspectorCollectionFields(
                  enabled: true,
                  condition: ownedItem!.condition,
                  grade: ownedItem!.grade,
                  conditions: type.conditions,
                  grades: type.grades,
                  accent: accent,
                  onConditionChanged: (value) => _updateConditionGrade(
                    context,
                    ref,
                    ownedItem!,
                    condition: value,
                    grade: ownedItem!.grade,
                  ),
                  onGradeChanged: (value) => _updateConditionGrade(
                    context,
                    ref,
                    ownedItem!,
                    condition: ownedItem!.condition,
                    grade: value,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              GenericMetadataSection(
                type: type,
                entry: selected,
                accent: accent,
                onFilterByValue: onFilterByValue,
              ),
              GenericPersonalSection(
                entry: selected,
                ownedItem: ownedItem,
                accent: accent,
                kind: type.workspace.kind,
              ),
              if (ownedItem != null)
                InspectorPersonalDetailsEditor(
                  ownedItem: ownedItem!,
                  accent: accent,
                ),
              if (ownedItem != null && db != null) ...[                InspectorCustomFieldsSection(
                  ownedItemId: ownedItem!.id,
                  mediaKind: type.workspace.kind,
                  db: db!,
                  accent: accent,
                ),
                InspectorItemImagesSection(
                  ownedItemId: ownedItem!.id,
                  db: db!,
                  accent: accent,
                ),
              ],
              if (selected.synopsis != null &&
                  selected.synopsis!.trim().isNotEmpty)
                LibraryInspectorSection(
                  title: 'Summary',
                  accentColor: accent,
                  children: [
                    Text(
                      selected.synopsis!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              if (type.supportedMetadataProviders.isNotEmpty)
                LibraryInspectorSection(
                  title: 'Providers',
                  accentColor: accent,
                  children: [
                    LibraryInspectorChipWrap(
                      values: [
                        for (final provider in type.supportedMetadataProviders)
                          provider.label,
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _updateConditionGrade(
    BuildContext context,
    WidgetRef ref,
    OwnedItem item, {
    required String? condition,
    required String? grade,
  }) async {
    await ref.read(collectionMutationsProvider).updateItem(
          item,
          condition: condition,
          grade: grade,
          purchaseDate: item.purchaseDate,
          pricePaidCents: item.pricePaidCents,
          currency: item.currency,
          personalNotes: item.personalNotes,
          quantity: item.quantity,
          storageBox: item.storageBox,
          indexNumber: item.indexNumber,
          coverPriceCents: item.coverPriceCents,
          rawOrSlabbed: item.rawOrSlabbed,
          gradingCompany: item.gradingCompany,
          graderNotes: item.graderNotes,
          signedBy: item.signedBy,
          keyComic: item.keyComic,
          keyReason: item.keyReason,
          rating: item.rating,
          readStatus: item.readStatus,
          tags: item.tags,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection details updated')),
      );
    }
  }
}
