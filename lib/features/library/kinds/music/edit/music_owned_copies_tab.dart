import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_entity_ownership.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_owned_copy_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildMusicOwnedCopiesTab({
  required CatalogSearchCandidate item,
  required MusicRelease release,
  required Color accent,
  required LibraryKindRegistration type,
}) {
  return _MusicOwnedCopiesTab(
    item: item,
    release: release,
    accent: accent,
    type: type,
  );
}

final class _MusicOwnedCopiesTab extends ConsumerStatefulWidget {
  const _MusicOwnedCopiesTab({
    required this.item,
    required this.release,
    required this.accent,
    required this.type,
  });

  final CatalogSearchCandidate item;
  final MusicRelease release;
  final Color accent;
  final LibraryKindRegistration type;

  @override
  ConsumerState<_MusicOwnedCopiesTab> createState() =>
      _MusicOwnedCopiesTabState();
}

final class _MusicOwnedCopiesTabState
    extends ConsumerState<_MusicOwnedCopiesTab> {
  late Future<List<MusicOwnedItem>> _copies;

  CatalogEntityRef get _releaseRef => musicReleaseRefForRoot(
        widget.item.reference,
        widget.release.id.value,
      );

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _copies = MusicOwnedRepository(ref.read(localDatabaseProvider))
        .listByReleaseRef(_releaseRef);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MusicOwnedItem>>(
      future: _copies,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Text('Unable to load owned copies: ${snapshot.error}');
        }
        final copies = snapshot.data ?? const <MusicOwnedItem>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    copies.isEmpty
                        ? 'No owned copies for this release.'
                        : '${copies.length} owned ${copies.length == 1 ? 'copy' : 'copies'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _createCopy(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add copy'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final copy in copies) ...[
              _CopyTile(
                copy: copy,
                accent: widget.accent,
                onEdit: () => _editCopy(context, copy),
                onDelete: () => _deleteCopy(context, copy),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }

  Future<void> _createCopy(BuildContext context) async {
    final values = await _showCopyForm(context);
    if (values == null || !mounted || !context.mounted) return;
    final payload = MusicOwnedItemCreatePayload(
      catalogRef: widget.item.reference,
      releaseRef: _releaseRef,
      details: values.details,
      condition: values.condition,
      grade: values.grade,
      purchaseStore: values.purchaseStore,
      personalNotes: values.personalNotes,
      pricePaidCents: values.pricePaidCents,
    );
    await ref.read(ownedItemMutationsProvider).addOwnedItem(
          AddOwnedItemCommand(
            catalogRef: widget.item.reference,
            typedPayload: payload,
            targetRef: _releaseRef,
          ),
        );
    if (!mounted || !context.mounted) return;
    setState(_reload);
  }

  Future<void> _editCopy(BuildContext context, MusicOwnedItem copy) async {
    final db = ref.read(localDatabaseProvider);
    final ownedRef = _ownedRef(copy);
    final dispatch = OpaqueLibraryOwnedItemDispatch(
      ref: ownedRef,
      kind: CatalogMediaKind.music,
      value: copy,
    );
    final request = LibraryEditDialogRequest(
      type: widget.type,
      item: widget.item,
      node: LibraryCopyRef(
        workId: widget.item.reference.rootId ?? widget.item.reference.id,
        releaseId: widget.release.id.value,
        ownedRef: ownedRef,
        copyId: copy.id.value,
      ),
      ownedItem: MusicOwnedItemProjection.toSummary(copy),
      ownedItemDispatch: dispatch,
      accent: widget.accent,
      scope: LibraryEntityScope.copy,
      itemImages: await ItemImageRepository(db).listForOwnedRef(ownedRef),
    );
    if (!mounted || !context.mounted) return;
    final result = await showDialog<LibraryEditSelection>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          buildMusicOwnedCopyLibraryEditDialog(dialogContext, request),
    );
    final payload = result?.ownedUpdatePayload;
    if (result == null || payload == null || !mounted) return;
    await ref.read(collectionCommandCoordinatorProvider).updateOwnedItem(
          UpdateOwnedItemCommand(ownedRef: ownedRef, payload: payload),
          syncTracking: false,
        );
    final imageRepository = ItemImageRepository(db);
    final now = DateTime.now();
    for (final edit in result.itemImageEdits) {
      if (edit.deleted) {
        await imageRepository.delete(edit.id);
      } else if (edit.imageData != null) {
        await imageRepository.add(ItemImage(
          id: edit.id,
          ownedRef: ownedRef,
          imageType: edit.imageType,
          imageData: edit.imageData!,
          caption: edit.caption,
          sortOrder: edit.sortOrder,
          createdAt: edit.createdAt ?? now,
        ));
      } else {
        await imageRepository.updateMetadata(
          edit.id,
          caption: edit.caption,
          imageType: edit.imageType,
          sortOrder: edit.sortOrder,
        );
      }
    }
    if (!mounted) return;
    setState(_reload);
  }

  Future<void> _deleteCopy(BuildContext context, MusicOwnedItem copy) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AccentAlertDialog(
        title: const Text('Remove owned copy?'),
        content: const Text('This copy will be removed from the collection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || !context.mounted) return;
    await ref.read(ownedItemMutationsProvider).removeItem(_ownedRef(copy));
    if (!mounted) return;
    setState(_reload);
  }

  Future<_CopyFormValues?> _showCopyForm(BuildContext context) {
    return showDialog<_CopyFormValues>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CopyFormDialog(
        release: widget.release,
      ),
    );
  }
}

final class _CopyTile extends StatelessWidget {
  const _CopyTile({
    required this.copy,
    required this.accent,
    required this.onEdit,
    required this.onDelete,
  });

  final MusicOwnedItem copy;
  final Color accent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        dense: true,
        leading: Icon(Icons.album_outlined, color: accent),
        title: Text(
            copy.grade?.trim().isNotEmpty == true ? copy.grade! : 'Owned copy'),
        subtitle: Text([
          if (copy.condition?.trim().isNotEmpty == true) copy.condition!,
          if (copy.purchaseStore?.trim().isNotEmpty == true)
            copy.purchaseStore!,
          for (final medium in copy.details.media)
            if (medium.storageDevice?.trim().isNotEmpty == true)
              medium.storageDevice!,
        ].join(' / ')),
        trailing: Wrap(
          spacing: 2,
          children: [
            IconButton(
              tooltip: 'Edit copy',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
            ),
            IconButton(
              tooltip: 'Remove copy',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

final class _CopyFormValues {
  const _CopyFormValues({
    required this.condition,
    required this.grade,
    required this.purchaseStore,
    required this.personalNotes,
    required this.pricePaidCents,
    required this.details,
  });

  final String? condition;
  final String? grade;
  final String? purchaseStore;
  final String? personalNotes;
  final int? pricePaidCents;
  final MusicOwnedDetailsDraft details;
}

final class _CopyFormDialog extends StatefulWidget {
  const _CopyFormDialog({required this.release});

  final MusicRelease release;

  @override
  State<_CopyFormDialog> createState() => _CopyFormDialogState();
}

final class _CopyFormDialogState extends State<_CopyFormDialog> {
  late final TextEditingController _condition;
  late final TextEditingController _grade;
  late final TextEditingController _store;
  late final TextEditingController _notes;
  late final TextEditingController _price;
  late final List<_MediumDetailsControllers> _mediums;

  @override
  void initState() {
    super.initState();
    _condition = TextEditingController();
    _grade = TextEditingController();
    _store = TextEditingController();
    _notes = TextEditingController();
    _price = TextEditingController();
    final mediumNumbers = widget.release.mediums.isEmpty
        ? const <int>[1]
        : [for (final medium in widget.release.mediums) medium.mediumNumber];
    _mediums = [
      for (final mediumNumber in mediumNumbers)
        _MediumDetailsControllers.fromDetails(
          mediumNumber,
          null,
        ),
    ];
  }

  @override
  void dispose() {
    for (final controller in [
      _condition,
      _grade,
      _store,
      _notes,
      _price,
      for (final medium in _mediums) ...medium.controllers,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      title: const Text('Add owned copy'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_condition, 'Condition'),
            _field(_grade, 'Grade'),
            for (final medium in _mediums) ...[
              if (_mediums.length > 1 || medium.mediumNumber != 1)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Disc ${medium.mediumNumber}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              _field(medium.storageDevice, 'Storage device'),
              _field(medium.mediaCondition, 'Media condition'),
              _field(medium.storageSlot, 'Storage slot'),
              _field(
                medium.matrixRunouts,
                'Matrix / runouts',
                maxLines: 3,
              ),
            ],
            _field(_store, 'Purchase store'),
            TextField(
              controller: _price,
              decoration: const InputDecoration(labelText: 'Price paid'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            _field(_notes, 'Notes', maxLines: 3),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final price = double.tryParse(_price.text.trim());
            Navigator.of(context).pop(
              _CopyFormValues(
                condition: _nullable(_condition.text),
                grade: _nullable(_grade.text),
                purchaseStore: _nullable(_store.text),
                personalNotes: _nullable(_notes.text),
                pricePaidCents: price == null ? null : (price * 100).round(),
                details: MusicOwnedDetailsDraft(
                  media: [
                    for (final medium in _mediums) medium.toDetails(),
                  ],
                ),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }
}

final class _MediumDetailsControllers {
  _MediumDetailsControllers({
    required this.mediumNumber,
    required this.storageDevice,
    required this.mediaCondition,
    required this.storageSlot,
    required this.matrixRunouts,
  });

  factory _MediumDetailsControllers.fromDetails(
    int mediumNumber,
    MusicOwnedMediumDetails? details,
  ) {
    final runouts = details?.matrixRunouts ?? const <MusicMatrixRunout>[];
    return _MediumDetailsControllers(
      mediumNumber: mediumNumber,
      storageDevice: TextEditingController(text: details?.storageDevice ?? ''),
      mediaCondition: TextEditingController(
        text: details?.mediaCondition ?? '',
      ),
      storageSlot: TextEditingController(text: details?.storageSlot ?? ''),
      matrixRunouts: TextEditingController(
        text: [
          for (final runout in runouts) '${runout.side}: ${runout.runoutText}',
        ].join('\n'),
      ),
    );
  }

  final int mediumNumber;
  final TextEditingController storageDevice;
  final TextEditingController mediaCondition;
  final TextEditingController storageSlot;
  final TextEditingController matrixRunouts;

  List<TextEditingController> get controllers => [
        storageDevice,
        mediaCondition,
        storageSlot,
        matrixRunouts,
      ];

  MusicOwnedMediumDetails toDetails() {
    final runouts = <MusicMatrixRunout>[];
    for (final rawLine in matrixRunouts.text.split(RegExp(r'[\r\n]+'))) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      final separator = line.indexOf(':');
      final side = separator < 0 ? 'A' : line.substring(0, separator).trim();
      final text = separator < 0 ? line : line.substring(separator + 1).trim();
      if (text.isEmpty) continue;
      runouts.add(MusicMatrixRunout(side: side, runoutText: text));
    }
    return MusicOwnedMediumDetails(
      mediumIndex: mediumNumber,
      mediaCondition: _nullable(mediaCondition.text),
      storageDevice: _nullable(storageDevice.text),
      storageSlot: _nullable(storageSlot.text),
      matrixRunouts: runouts,
    );
  }

  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
  }
}

String? _nullable(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

OwnedItemRef _ownedRef(MusicOwnedItem item) => OwnedItemRef(
      kind: CatalogMediaKind.music,
      id: OwnedItemId(item.id.value),
    );
