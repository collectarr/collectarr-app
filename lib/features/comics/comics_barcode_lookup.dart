import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:flutter/material.dart';

enum BarcodeLookupStatus {
  pending,
  lookingUp,
  found,
  missing;

  String get label => switch (this) {
        BarcodeLookupStatus.pending => 'Pending',
        BarcodeLookupStatus.lookingUp => 'Looking up',
        BarcodeLookupStatus.found => 'Found',
        BarcodeLookupStatus.missing => 'Not found',
      };

  IconData get icon => switch (this) {
        BarcodeLookupStatus.pending => Icons.schedule,
        BarcodeLookupStatus.lookingUp => Icons.sync,
        BarcodeLookupStatus.found => Icons.check_circle,
        BarcodeLookupStatus.missing => Icons.error_outline,
      };

  Color get color => switch (this) {
        BarcodeLookupStatus.pending => const Color(0xFFB8B8B8),
        BarcodeLookupStatus.lookingUp => const Color(0xFF18B7EB),
        BarcodeLookupStatus.found => const Color(0xFF59D17D),
        BarcodeLookupStatus.missing => const Color(0xFFFFC857),
      };
}

class BarcodeLookupEntry {
  const BarcodeLookupEntry({
    required this.code,
    required this.status,
    this.item,
    this.error,
  });

  factory BarcodeLookupEntry.pending(String code) {
    return BarcodeLookupEntry(
      code: code,
      status: BarcodeLookupStatus.pending,
    );
  }

  factory BarcodeLookupEntry.lookingUp(String code) {
    return BarcodeLookupEntry(
      code: code,
      status: BarcodeLookupStatus.lookingUp,
    );
  }

  factory BarcodeLookupEntry.found({
    required String code,
    required CatalogItem item,
  }) {
    return BarcodeLookupEntry(
      code: code,
      status: BarcodeLookupStatus.found,
      item: item,
    );
  }

  factory BarcodeLookupEntry.missing(String code) {
    return BarcodeLookupEntry(
      code: code,
      status: BarcodeLookupStatus.missing,
      error: 'No match',
    );
  }

  final String code;
  final BarcodeLookupStatus status;
  final CatalogItem? item;
  final String? error;

  BarcodeLookupEntry copyWith({
    BarcodeLookupStatus? status,
    CatalogItem? item,
    String? error,
  }) {
    return BarcodeLookupEntry(
      code: code,
      status: status ?? this.status,
      item: item ?? this.item,
      error: error,
    );
  }
}

class BarcodeLookupStrip extends StatelessWidget {
  const BarcodeLookupStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        border: Border.all(color: const Color(0xFF555555)),
      ),
      child: const Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _BarcodeInfoChip(
            icon: Icons.radio_button_checked,
            label: 'Connected',
          ),
          _BarcodeInfoChip(
            icon: Icons.center_focus_strong,
            label: 'Camera scan',
          ),
          _BarcodeInfoChip(icon: Icons.keyboard, label: 'Manual UPC/EAN'),
          _BarcodeInfoChip(
            icon: Icons.cleaning_services,
            label: 'Auto-normalize',
          ),
        ],
      ),
    );
  }
}

class BarcodeHistoryStrip extends StatelessWidget {
  const BarcodeHistoryStrip({
    super.key,
    required this.codes,
    required this.onUse,
  });

  final List<String> codes;
  final ValueChanged<String> onUse;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            'Recent',
            style: TextStyle(
              color: Color(0xFFB8B8B8),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (final code in codes)
                ActionChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(code),
                  avatar: const Icon(Icons.history, size: 16),
                  onPressed: () => onUse(code),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class BarcodeBatchPanel extends StatelessWidget {
  const BarcodeBatchPanel({
    super.key,
    required this.entries,
    required this.isLookingUp,
    required this.addableCount,
    required this.addFoundLabel,
    required this.onLookupAll,
    required this.onAddFound,
    required this.onRemove,
    required this.onClear,
  });

  final List<BarcodeLookupEntry> entries;
  final bool isLookingUp;
  final int addableCount;
  final String addFoundLabel;
  final VoidCallback onLookupAll;
  final VoidCallback? onAddFound;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final found = entries.where((entry) => entry.item != null).length;
    final missing = entries
        .where((entry) => entry.status == BarcodeLookupStatus.missing)
        .length;
    final pending = entries
        .where((entry) => entry.status == BarcodeLookupStatus.pending)
        .length;
    final lookingUp = entries
        .where((entry) => entry.status == BarcodeLookupStatus.lookingUp)
        .length;
    return Container(
      constraints: const BoxConstraints(maxHeight: 190),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        border: Border.all(color: const Color(0xFF555555)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
            decoration: const BoxDecoration(
              color: Color(0xFF282828),
              border: Border(bottom: BorderSide(color: Color(0xFF444444))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      LibraryAddResultBadge('${entries.length} scanned'),
                      LibraryAddResultBadge('$found found'),
                      if (pending > 0)
                        LibraryAddResultBadge('$pending pending'),
                      if (lookingUp > 0)
                        LibraryAddResultBadge('$lookingUp active'),
                      if (missing > 0)
                        LibraryAddResultBadge('$missing missing'),
                      if (addableCount != found)
                        LibraryAddResultBadge('$addableCount addable'),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed:
                      isLookingUp || addableCount == 0 ? null : onAddFound,
                  child: Text(addFoundLabel),
                ),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: isLookingUp ? null : onLookupAll,
                  child: const Text('Lookup all'),
                ),
                TextButton(
                  onPressed: isLookingUp ? null : onClear,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return BarcodeBatchRow(
                  entry: entry,
                  onRemove: () => onRemove(entry.code),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BarcodeBatchRow extends StatelessWidget {
  const BarcodeBatchRow({
    super.key,
    required this.entry,
    required this.onRemove,
  });

  final BarcodeLookupEntry entry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final item = entry.item;
    final label = item == null
        ? entry.status.label
        : item.itemNumber == null
            ? item.title
            : '${item.title} #${item.itemNumber}';
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 4, 5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF333333))),
      ),
      child: Row(
        children: [
          Icon(entry.status.icon, size: 16, color: entry.status.color),
          const SizedBox(width: 7),
          SizedBox(
            width: 128,
            child: Text(
              entry.code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFeatures: []),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: item == null ? const Color(0xFFCCCCCC) : Colors.white,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Remove barcode',
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 16),
          ),
        ],
      ),
    );
  }
}

class _BarcodeInfoChip extends StatelessWidget {
  const _BarcodeInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF59D17D), size: 15),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
