import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/reading_queue_repository.dart';
import 'package:collectarr_app/features/library/detail/library_detail_launcher.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_hero.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_sections.dart';
import 'package:collectarr_app/features/library/inspector/metadata_correction_dialog.dart';
import 'package:collectarr_app/features/library/inspector/inspector_custom_fields_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_item_images_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_loan_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_location_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_folder_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_reading_queue_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryInspector extends ConsumerStatefulWidget {
  const LibraryInspector({
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
  final void Function(OwnedItem? ownedItem)? onEdit;
  final ValueChanged<String>? onFilterByValue;
  final LocalDatabase? db;

  @override
  ConsumerState<LibraryInspector> createState() => _LibraryInspectorState();
}

class _LibraryInspectorState extends ConsumerState<LibraryInspector> {
  String? _selectedOwnedItemId;
  bool _selectNewestOwnedItem = false;

  @override
  void initState() {
    super.initState();
    _selectedOwnedItemId = widget.ownedItem?.id;
  }

  @override
  void didUpdateWidget(covariant LibraryInspector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entry?.id != oldWidget.entry?.id) {
      _selectedOwnedItemId = widget.ownedItem?.id;
      _selectNewestOwnedItem = false;
      return;
    }
    if (widget.ownedItem?.id != oldWidget.ownedItem?.id &&
        widget.ownedItem != null &&
        _selectedOwnedItemId == null) {
      _selectedOwnedItemId = widget.ownedItem!.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.entry;
    if (selected == null) {
      return EmptyInspector(type: widget.type, accent: widget.accent);
    }
    final ownedCopies = ref.watch(collectionProvider).maybeWhen(
          data: (items) {
            final matches = items
                .where((item) => !item.isDeleted && item.itemId == selected.id)
                .toList(growable: false)
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            return matches;
          },
          orElse: () => widget.ownedItem == null
              ? const <OwnedItem>[]
              : <OwnedItem>[widget.ownedItem!],
        );
    final activeOwnedItem = _resolveOwnedItem(ownedCopies, widget.ownedItem);
    final extraActions = <Widget>[
      if (selected.isOwned)
        _InspectorDialogActionButton(
          tooltip: 'Add another copy',
          icon: Icons.copy_all_outlined,
          onPressed: () => _addOwnedCopy(selected.id),
        ),
      if (activeOwnedItem != null && widget.db != null)
        _InspectorDialogActionButton(
          tooltip: 'Manage location',
          icon: Icons.place_outlined,
          onPressed: () => _showOwnedSectionDialog(
            context,
            title: 'Location',
            child: InspectorLocationSection(
              ownedItemId: activeOwnedItem.id,
              db: widget.db!,
              accent: widget.accent,
            ),
          ),
        ),
      if (activeOwnedItem != null && widget.db != null)
        _InspectorDialogActionButton(
          tooltip: 'Manage folders',
          icon: Icons.folder_open_outlined,
          onPressed: () => _showOwnedSectionDialog(
            context,
            title: 'Folders',
            child: InspectorFolderSection(
              ownedItemId: activeOwnedItem.id,
              db: widget.db!,
              accent: widget.accent,
            ),
          ),
        ),
      if (activeOwnedItem != null && widget.db != null)
        _InspectorDialogActionButton(
          tooltip: 'Manage loans',
          icon: Icons.handshake_outlined,
          onPressed: () => _showOwnedSectionDialog(
            context,
            title: 'Loans',
            child: InspectorLoanSection(
              ownedItemId: activeOwnedItem.id,
              db: widget.db!,
              accent: widget.accent,
            ),
          ),
        ),
      if (activeOwnedItem != null &&
          widget.db != null &&
          libraryShowsReadingQueue(widget.type.workspace.kind))
        _InspectorReadingQueueActionButton(
          ownedItemId: activeOwnedItem.id,
          db: widget.db!,
          accent: widget.accent,
        ),
    ];
    return Stack(
      children: [
        Positioned.fill(
          child: InspectorBackdrop(entry: selected),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(color: Color(0xBA111111)),
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              InspectorActionBar(
                type: widget.type,
                entry: selected,
                onToggleOwned: selected.isOwned
                    ? activeOwnedItem == null
                        ? widget.onRemoveOwned
                        : () => _removeOwnedCopy(activeOwnedItem)
                    : widget.onAddOwned,
                onToggleWishlist:
                    selected.isWishlisted ? widget.onRemoveWishlist : widget.onAddWishlist,
                onEdit: widget.onEdit == null
                  ? null
                  : () => widget.onEdit!(activeOwnedItem),
                onCorrectMetadata: widget.type.supportedMetadataProviders.isNotEmpty
                    ? () => showMetadataCorrectionDialog(
                          context: context,
                          ref: ref,
                          item: CatalogItem(
                            id: selected.id,
                            kind: widget.type.workspace.kind,
                            title: selected.title,
                            itemNumber: selected.itemNumber,
                            publisher: selected.publisher,
                            releaseYear: selected.releaseYear,
                            barcode: selected.barcode,
                            variant: selected.variant,
                          ),
                          type: widget.type,
                        )
                    : null,
                extraActions: extraActions,
                onOpenDetails: () => showLibraryDetailPage(
                  context: context,
                  request: LibraryDetailPageRequest(
                    type: widget.type,
                    entry: selected,
                    ownedItem: activeOwnedItem,
                    accent: widget.accent,
                    onAddOwned: selected.isOwned
                        ? () => _addOwnedCopy(selected.id)
                        : widget.onAddOwned,
                    onRemoveOwned: activeOwnedItem == null
                        ? widget.onRemoveOwned
                        : () => _removeOwnedCopy(activeOwnedItem),
                    onAddWishlist: widget.onAddWishlist,
                    onRemoveWishlist: widget.onRemoveWishlist,
                    onEdit: widget.onEdit,
                    onFilterByValue: widget.onFilterByValue,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              InspectorHero(
                type: widget.type,
                entry: selected,
                ownedItem: activeOwnedItem,
                accent: widget.accent,
              ),
              if (ownedCopies.isNotEmpty) ...[
                const SizedBox(height: 10),
                _InspectorOwnedCopiesSection(
                  copies: ownedCopies,
                  selectedOwnedItemId: activeOwnedItem?.id,
                  accent: widget.accent,
                    onAddCopy: () => _addOwnedCopy(selected.id),
                  onSelected: ownedCopies.length < 2
                      ? null
                      : (value) => setState(() => _selectedOwnedItemId = value),
                ),
              ],
              if (activeOwnedItem != null &&
                  (widget.type.conditions.isNotEmpty || widget.type.grades.isNotEmpty)) ...[
                const SizedBox(height: 10),
                InspectorCollectionFields(
                  enabled: true,
                  condition: activeOwnedItem.condition,
                  grade: activeOwnedItem.grade,
                  conditions: widget.type.conditions,
                  grades: widget.type.grades,
                  accent: widget.accent,
                  onConditionChanged: (value) => _updateConditionGrade(
                    context,
                    activeOwnedItem,
                    condition: value,
                    grade: activeOwnedItem.grade,
                  ),
                  onGradeChanged: (value) => _updateConditionGrade(
                    context,
                    activeOwnedItem,
                    condition: activeOwnedItem.condition,
                    grade: value,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              InspectorMetadataSection(
                type: widget.type,
                entry: selected,
                accent: widget.accent,
                onFilterByValue: widget.onFilterByValue,
              ),
              InspectorPersonalSection(
                entry: selected,
                ownedItem: activeOwnedItem,
                accent: widget.accent,
                kind: widget.type.workspace.kind,
              ),
              if (activeOwnedItem != null)
                InspectorPersonalDetailsEditor(
                  ownedItem: activeOwnedItem,
                  accent: widget.accent,
                ),
              if (activeOwnedItem != null && widget.db != null) ...[
                InspectorCustomFieldsSection(
                  ownedItemId: activeOwnedItem.id,
                  mediaKind: widget.type.workspace.kind,
                  db: widget.db!,
                  accent: widget.accent,
                ),
                if (widget.type.workspace.kind != 'book')
                  InspectorItemImagesSection(
                    ownedItemId: activeOwnedItem.id,
                    db: widget.db!,
                    accent: widget.accent,
                  ),
              ],
              ...widget.type.presentation.builder.buildInspectorSections(
                context: context,
                entry: selected,
                accent: widget.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _updateConditionGrade(
    BuildContext context,
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

  Future<void> _showOwnedSectionDialog(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  OwnedItem? _resolveOwnedItem(
    List<OwnedItem> ownedCopies,
    OwnedItem? fallback,
  ) {
    if (ownedCopies.isEmpty) {
      return fallback;
    }
    if (_selectNewestOwnedItem) {
      final newest = ownedCopies.first;
      _scheduleOwnedCopySelection(newest.id, clearNewest: true);
      return newest;
    }
    if (_selectedOwnedItemId != null) {
      for (final item in ownedCopies) {
        if (item.id == _selectedOwnedItemId) {
          return item;
        }
      }
    }
    final resolved = fallback != null
        ? ownedCopies.firstWhere(
            (item) => item.id == fallback.id,
            orElse: () => ownedCopies.first,
          )
        : ownedCopies.first;
    if (_selectedOwnedItemId != resolved.id) {
      _scheduleOwnedCopySelection(resolved.id);
    }
    return resolved;
  }

  void _scheduleOwnedCopySelection(
    String ownedItemId, {
    bool clearNewest = true,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedOwnedItemId = ownedItemId;
        if (clearNewest) {
          _selectNewestOwnedItem = false;
        }
      });
    });
  }

  Future<void> _addOwnedCopy(String itemId) async {
    await ref.read(collectionMutationsProvider).addItem(itemId);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedOwnedItemId = null;
      _selectNewestOwnedItem = true;
    });
  }

  Future<void> _removeOwnedCopy(OwnedItem item) async {
    await ref.read(collectionMutationsProvider).removeItem(item);
    if (!mounted) {
      return;
    }
    setState(() {
      if (_selectedOwnedItemId == item.id) {
        _selectedOwnedItemId = null;
      }
      _selectNewestOwnedItem = false;
    });
  }
}

class _InspectorOwnedCopiesSection extends StatelessWidget {
  const _InspectorOwnedCopiesSection({
    required this.copies,
    required this.selectedOwnedItemId,
    required this.accent,
    required this.onAddCopy,
    this.onSelected,
  });

  final List<OwnedItem> copies;
  final String? selectedOwnedItemId;
  final Color accent;
  final VoidCallback onAddCopy;
  final ValueChanged<String?>? onSelected;

  @override
  Widget build(BuildContext context) {
    return LibraryInspectorSection(
      title: copies.length == 1 ? 'Copy' : 'Copies',
      accentColor: accent,
      children: [
        Row(
          children: [
            Expanded(
              child: copies.length < 2
                  ? Text(
                      '1 copy in collection',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    )
                  : DropdownButtonFormField<String>(
                      value: selectedOwnedItemId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Active copy',
                      ),
                      items: [
                        for (var index = 0; index < copies.length; index += 1)
                          DropdownMenuItem<String>(
                            value: copies[index].id,
                            child: Text(
                              _ownedCopyLabel(copies[index], index),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: onSelected,
                    ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onAddCopy,
              icon: const Icon(Icons.copy_all_outlined),
              label: const Text('Add copy'),
            ),
          ],
        ),
        if (copies.length > 1) ...[
          const SizedBox(height: 8),
          Text(
            '${copies.length} copies in collection',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }
}

String _ownedCopyLabel(OwnedItem item, int index) {
  final parts = <String>['Copy ${index + 1}'];
  if (item.condition != null && item.condition!.trim().isNotEmpty) {
    parts.add(item.condition!.trim());
  }
  if (item.grade != null && item.grade!.trim().isNotEmpty) {
    parts.add(item.grade!.trim());
  }
  if (item.storageBox != null && item.storageBox!.trim().isNotEmpty) {
    parts.add(item.storageBox!.trim());
  }
  final purchaseLabel = formatNullableDate(item.purchaseDate);
  if (purchaseLabel != null) {
    parts.add(purchaseLabel);
  }
  return parts.join('  ·  ');
}

class _InspectorDialogActionButton extends StatelessWidget {
  const _InspectorDialogActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: 28,
        child: IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
        ),
      ),
    );
  }
}

class _InspectorReadingQueueActionButton extends StatefulWidget {
  const _InspectorReadingQueueActionButton({
    required this.ownedItemId,
    required this.db,
    required this.accent,
  });

  final String ownedItemId;
  final LocalDatabase db;
  final Color accent;

  @override
  State<_InspectorReadingQueueActionButton> createState() =>
      _InspectorReadingQueueActionButtonState();
}

class _InspectorReadingQueueActionButtonState
    extends State<_InspectorReadingQueueActionButton> {
  bool _loading = true;
  bool _inQueue = false;
  int? _position;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final queue = await ReadingQueueRepository(widget.db).getQueue();
    final index = queue.indexOf(widget.ownedItemId);
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      _inQueue = index >= 0;
      _position = index >= 0 ? index + 1 : null;
    });
  }

  Future<void> _openDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: InspectorReadingQueueSection(
              ownedItemId: widget.ownedItemId,
              db: widget.db,
              accent: widget.accent,
            ),
          ),
        ),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final tooltip = _loading
        ? 'Reading queue'
        : _inQueue
            ? 'Reading queue · position #$_position'
            : 'Add to reading queue';
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: 28,
        child: IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          onPressed: _openDialog,
          icon: Icon(
            _inQueue ? Icons.bookmark : Icons.bookmark_border,
            size: 16,
            color: _inQueue ? widget.accent : null,
          ),
        ),
      ),
    );
  }
}
