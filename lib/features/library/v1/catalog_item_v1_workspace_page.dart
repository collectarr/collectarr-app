import 'dart:convert';

import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/barcode/scanned_code.dart';
import 'package:collectarr_app/features/library/data/catalog_item_v1_workspace_repository.dart';
import 'package:collectarr_app/features/library/domain/owned_copy_v1.dart';
import 'package:collectarr_app/features/library/domain/catalog_item_v1_schema.dart';
import 'package:collectarr_app/features/library/state/catalog_item_v1_providers.dart';
import 'package:collectarr_app/features/library/v1/owned_copy_v1_form.dart';
import 'package:collectarr_app/features/library/v1/catalog_item_v1_cover_panel.dart';
import 'package:collectarr_app/features/library/config/library_kind_identity.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'catalog_item_v1_workspace_list.dart';
part 'catalog_item_v1_add_dialog.dart';
part 'catalog_item_v1_schema_fields.dart';
part 'catalog_item_v1_edit_dialog.dart';

/// Active Catalog Item + Owned Copy workspace shared by all library kinds.
final class CatalogItemV1WorkspacePage extends ConsumerWidget {
  const CatalogItemV1WorkspacePage({
    required this.kind,
    required this.identity,
    required this.topBar,
    required this.accent,
    super.key,
  });

  final CatalogMediaKind kind;
  final LibraryKindIdentity identity;
  final Widget topBar;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(catalogItemV1WorkspaceByKindProvider(kind));
    final canEditCatalog = ref.watch(authControllerProvider).canEditCatalog;
    return Column(
      children: [
        topBar,
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        identity.pluralLabel,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh Catalog Items',
                      onPressed: () {
                        ref
                            .read(catalogItemV1WorkspaceRepositoryProvider)
                            .clearCatalogCache();
                        ref.invalidate(
                          catalogItemV1WorkspaceByKindProvider(kind),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                    FilledButton.icon(
                      onPressed: () => _openAddDialog(
                        context,
                        canEditCatalog: canEditCatalog,
                      ),
                      icon: const Icon(Icons.add),
                      label: Text('Add ${identity.singularLabel}'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: workspace.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: _WorkspaceMessage(
                      icon: Icons.error_outline,
                      message: 'Could not load owned copies: $error',
                    ),
                  ),
                  data: (items) => _CatalogItemWorkspaceList(
                    items: items,
                    identity: identity,
                    accent: accent,
                    canEditCatalog: canEditCatalog,
                    onEditCatalog: (item) => _editCatalogItem(
                      context,
                      ref,
                      item.catalogItem!,
                    ),
                    onEditCopy: (copy) => _editOwnedCopy(context, ref, copy),
                    onAddCopy: (item) => _addOwnedCopies(context, ref, item),
                    onDeleteCopy: (copy) =>
                        _deleteOwnedCopy(context, ref, copy),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openAddDialog(
    BuildContext context, {
    required bool canEditCatalog,
  }) async {
    await showCatalogItemV1AddDialog(
      context: context,
      kind: kind,
      singularLabel: identity.singularLabel,
      accent: accent,
      canEditCatalog: canEditCatalog,
    );
  }

  Future<void> _editCatalogItem(
    BuildContext context,
    WidgetRef ref,
    CatalogItemV1Dto item,
  ) async {
    final result = await showDialog<CatalogItemWriteV1Dto>(
      context: context,
      builder: (context) => _CatalogItemCommonEditor(
        title: 'Edit ${identity.singularLabel}',
        accent: accent,
        kind: item.reference.kind,
        initialDetails: item.details.toJson(),
      ),
    );
    if (result == null || !context.mounted) return;
    try {
      final updated = await ref
          .read(libraryCatalogItemV1AddServiceProvider)
          .update(item.reference, result);
      ref.read(catalogItemV1WorkspaceRepositoryProvider).remember(updated);
      ref.invalidate(catalogItemV1WorkspaceByKindProvider(kind));
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, _catalogWriteError(error));
    }
  }

  Future<void> _editOwnedCopy(
    BuildContext context,
    WidgetRef ref,
    OwnedCopyV1 copy,
  ) async {
    final updated = await showDialog<OwnedCopyV1>(
      context: context,
      builder: (context) => _OwnedCopyEditor(
        copy: copy,
        title: identity.singularLabel,
        accent: accent,
      ),
    );
    if (updated == null || !context.mounted) return;
    try {
      await ref.read(ownedCopyV1RepositoryProvider).upsert(updated);
      ref.invalidate(catalogItemV1WorkspaceByKindProvider(kind));
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Could not save this copy: $error');
    }
  }

  Future<void> _addOwnedCopies(
    BuildContext context,
    WidgetRef ref,
    CatalogItemV1WorkspaceItem item,
  ) async {
    final draft = await showDialog<OwnedCopyV1FormDraft>(
      context: context,
      builder: (context) => _OwnedCopyAddDialog(
        title: item.title,
        kind: item.reference.kind,
        accent: accent,
      ),
    );
    if (draft == null || !context.mounted) return;
    final validationError = draft.validationError;
    if (validationError != null) {
      _showMessage(context, validationError);
      return;
    }
    try {
      await ref.read(libraryCatalogItemV1AddServiceProvider).addCopies(
            item: item.reference,
            quantity: draft.quantity,
            status: draft.status,
            startingIndex: draft.indexNumber,
            locationId: draft.locationId,
            owner: draft.owner,
            isDigital: draft.isDigital,
            condition: draft.condition,
            purchaseDate: draft.purchaseDate,
            purchasePrice: draft.purchasePrice,
            purchaseStore: draft.purchaseStore,
            currentValue: draft.currentValue,
            soldAt: draft.soldAt,
            soldTo: draft.soldTo,
            salePrice: draft.salePrice,
            rating: draft.rating,
            notes: draft.notes,
            tags: draft.tags,
            personalImages: draft.personalImages,
            customFields: draft.customFields,
            kindDetails: draft.kindDetails,
          );
      ref.invalidate(catalogItemV1WorkspaceByKindProvider(kind));
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Could not add this copy: $error');
    }
  }

  Future<void> _deleteOwnedCopy(
    BuildContext context,
    WidgetRef ref,
    OwnedCopyV1 copy,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove owned copy?'),
        content: Text(
            'Remove this ${identity.singularLabel} copy from your collection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref
          .read(ownedCopyV1RepositoryProvider)
          .markDeleted(copy.ref, DateTime.now().toUtc());
      ref.invalidate(catalogItemV1WorkspaceByKindProvider(kind));
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Could not remove this copy: $error');
    }
  }
}
