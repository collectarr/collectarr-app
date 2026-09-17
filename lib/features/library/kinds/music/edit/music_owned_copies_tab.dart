import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_entity_ownership.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildMusicOwnedCopiesTab({
  required CatalogSearchCandidate item,
  required MusicRelease release,
  required Color accent,
}) {
  return _MusicOwnedCopiesTab(
    item: item,
    release: release,
    accent: accent,
  );
}

final class _MusicOwnedCopiesTab extends ConsumerStatefulWidget {
  const _MusicOwnedCopiesTab({
    required this.item,
    required this.release,
    required this.accent,
  });

  final CatalogSearchCandidate item;
  final MusicRelease release;
  final Color accent;

  @override
  ConsumerState<_MusicOwnedCopiesTab> createState() =>
      _MusicOwnedCopiesTabState();
}

final class _MusicOwnedCopiesTabState
    extends ConsumerState<_MusicOwnedCopiesTab> {
  late Future<List<MusicOwnedItem>> _copies;

  CatalogEntityRef get _releaseRef => musicReleaseRefForRoot(
        widget.item.catalogRef,
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
    if (values == null || !mounted) return;
    final payload = MusicOwnedItemCreatePayload(
      catalogRef: widget.item.catalogRef,
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
            catalogRef: widget.item.catalogRef,
            typedPayload: payload,
            targetRef: _releaseRef,
          ),
        );
    if (!mounted) return;
    setState(_reload);
  }

  Future<void> _editCopy(BuildContext context, MusicOwnedItem copy) async {
    final values = await _showCopyForm(context, initial: copy);
    if (values == null || !mounted) return;
    final payload = MusicOwnedItemUpdatePayload.partial(
      targetRef: Patch.set(_releaseRef),
      quantity: Patch.set(copy.quantity),
      isDigital: Patch.set(copy.isDigital),
      condition: Patch.set(values.condition),
      grade: Patch.set(values.grade),
      purchaseDate: Patch.set(copy.purchaseDate),
      pricePaidCents: Patch.set(values.pricePaidCents),
      currency: Patch.set(copy.currency),
      personalNotes: Patch.set(values.personalNotes),
      locationId: Patch.set(copy.locationId),
      purchaseStore: Patch.set(values.purchaseStore),
      collectionStatus: Patch.set(copy.collectionStatus),
      tags: Patch.set(copy.tags),
      soldAt: Patch.set(copy.soldAt),
      sellPriceCents: Patch.set(copy.sellPriceCents),
      soldTo: Patch.set(copy.soldTo),
      marketValueCents: Patch.set(copy.marketValueCents),
      indexNumber: Patch.set(copy.indexNumber),
      details: Patch.set(values.details),
    );
    await ref.read(collectionCommandCoordinatorProvider).updateOwnedItem(
          UpdateOwnedItemCommand(ownedRef: _ownedRef(copy), payload: payload),
          syncTracking: false,
        );
    if (!mounted) return;
    setState(_reload);
  }

  Future<void> _deleteCopy(BuildContext context, MusicOwnedItem copy) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
    if (confirmed != true || !mounted) return;
    await ref.read(ownedItemMutationsProvider).removeItem(_ownedRef(copy));
    if (!mounted) return;
    setState(_reload);
  }

  Future<_CopyFormValues?> _showCopyForm(
    BuildContext context, {
    MusicOwnedItem? initial,
  }) {
    return showDialog<_CopyFormValues>(
      context: context,
      builder: (_) => _CopyFormDialog(
        initial: initial,
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
        ].join(' \u00B7 ')),
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
  const _CopyFormDialog({required this.release, this.initial});

  final MusicOwnedItem? initial;
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
    final copy = widget.initial;
    _condition = TextEditingController(text: copy?.condition ?? '');
    _grade = TextEditingController(text: copy?.grade ?? '');
    _store = TextEditingController(text: copy?.purchaseStore ?? '');
    _notes = TextEditingController(text: copy?.personalNotes ?? '');
    _price = TextEditingController(
      text: copy?.pricePaidCents == null
          ? ''
          : (copy!.pricePaidCents! / 100).toStringAsFixed(2),
    );
    final mediumNumbers = widget.release.mediums.isEmpty
        ? const <int>[1]
        : [for (final medium in widget.release.mediums) medium.mediumNumber];
    _mediums = [
      for (final mediumNumber in mediumNumbers)
        _MediumDetailsControllers.fromDetails(
          mediumNumber,
          copy?.details.medium(mediumNumber),
        ),
    ];
    final represented = {for (final entry in _mediums) entry.mediumNumber};
    for (final details
        in copy?.details.media ?? const <MusicOwnedMediumDetails>[]) {
      if (!represented.contains(details.mediumIndex)) {
        _mediums.add(
          _MediumDetailsControllers.fromDetails(
            details.mediumIndex,
            details,
          ),
        );
      }
    }
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
    return AlertDialog(
      title:
          Text(widget.initial == null ? 'Add owned copy' : 'Edit owned copy'),
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
                  signedBy: widget.initial?.details.signedBy,
                  lastCleanedDate: widget.initial?.details.lastCleanedDate,
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
  final TextEditingController storageSlot;
  final TextEditingController matrixRunouts;

  List<TextEditingController> get controllers => [
        storageDevice,
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
