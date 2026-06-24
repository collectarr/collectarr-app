import 'dart:async';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';

/// Data class for insurance value summary.
class InsuranceValueSummary {
  const InsuranceValueSummary({
    required this.totalItems,
    required this.itemsWithValue,
    required this.totalPaidCents,
    required this.totalCoverPriceCents,
    this.currency = 'USD',
  });

  final int totalItems;
  final int itemsWithValue;
  final int totalPaidCents;
  final int totalCoverPriceCents;
  final String currency;

  String get totalPaidFormatted => _formatCents(totalPaidCents);
  String get totalCoverPriceFormatted => _formatCents(totalCoverPriceCents);
  double get coveragePercent =>
      totalItems > 0 ? (itemsWithValue / totalItems * 100) : 0;

  static String _formatCents(int cents) {
    final dollars = cents / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }
}

/// Repository for calculating insurance/collection values.
class InsuranceValueRepository {
  InsuranceValueRepository(this._db);

  final LocalDatabase _db;

  Future<InsuranceValueSummary> getSummary({String? mediaKind}) async {
    // Count total owned items
    final countResult = await _db.customSelect(
      'SELECT COUNT(*) as cnt FROM owned_items_cache WHERE deleted_at IS NULL',
    ).getSingle();
    final totalItems = countResult.data['cnt'] as int;

    // Sum price_paid_cents
    final paidResult = await _db.customSelect(
      'SELECT COUNT(*) as cnt, COALESCE(SUM(price_paid_cents), 0) as total '
      'FROM owned_items_cache WHERE deleted_at IS NULL AND price_paid_cents IS NOT NULL',
    ).getSingle();
    final itemsWithValue = paidResult.data['cnt'] as int;
    final totalPaid = paidResult.data['total'] as int;

    // Sum cover_price_cents from catalog
    final coverResult = await _db.customSelect(
      'SELECT COALESCE(SUM(c.cover_price_cents), 0) as total '
      'FROM owned_items_cache o '
      'INNER JOIN catalog_cache c ON o.item_id = c.id '
      'WHERE o.deleted_at IS NULL AND c.cover_price_cents IS NOT NULL',
    ).getSingle();
    final totalCoverPrice = coverResult.data['total'] as int;

    return InsuranceValueSummary(
      totalItems: totalItems,
      itemsWithValue: itemsWithValue,
      totalPaidCents: totalPaid,
      totalCoverPriceCents: totalCoverPrice,
    );
  }
}

/// Dialog showing the collection insurance value summary.
Future<void> showInsuranceValueDialog({
  required BuildContext context,
  required LocalDatabase db,
}) async {
  final repo = InsuranceValueRepository(db);
  final summary = await repo.getSummary();
  if (!context.mounted) return;

  unawaited(showDialog<void>(
    context: context,
    builder: (_) => _InsuranceValueDialog(summary: summary),
  ));
}

class _InsuranceValueDialog extends StatelessWidget {
  const _InsuranceValueDialog({required this.summary});

  final InsuranceValueSummary summary;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return AccentAlertDialog(
      backgroundColor: palette.panel,
      title: const Row(
        children: [
          Icon(Icons.shield_outlined, size: 22),
          SizedBox(width: 8),
          Text('Collection Value'),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ValueRow(
              label: 'Total Items',
              value: summary.totalItems.toString(),
            ),
            _ValueRow(
              label: 'Items with Price',
              value:
                  '${summary.itemsWithValue} (${summary.coveragePercent.toStringAsFixed(0)}%)',
            ),
            const Divider(height: 24),
            _ValueRow(
              label: 'Total Paid',
              value: summary.totalPaidFormatted,
              highlight: true,
            ),
            _ValueRow(
              label: 'Total Cover Price',
              value: summary.totalCoverPriceFormatted,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.panelRaised,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: palette.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'For insurance purposes, consider using cover price '
                      'or current market value as the replacement cost.',
                      style: TextStyle(fontSize: 11, color: palette.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: palette.textMuted, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 16 : 13,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? Theme.of(context).colorScheme.primary : onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
