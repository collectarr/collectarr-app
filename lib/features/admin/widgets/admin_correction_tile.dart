import 'package:collectarr_app/core/api/dto/canonical_correction_proposal.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/metadata/metadata_diff_panel.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// One correction to an existing Core item: what it proposes beside what
/// Core holds now, in the comparison table users see when proposing.
final class AdminCorrectionTile extends StatelessWidget {
  const AdminCorrectionTile({
    required this.correction,
    required this.kindLabel,
    required this.fieldLabels,
    required this.isActing,
    required this.onApprove,
    required this.onReject,
    super.key,
  });

  final CanonicalCorrectionProposal correction;
  final String kindLabel;

  /// Core's labels for the proposed fields, by key.
  final Map<String, String> fieldLabels;
  final bool isActing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final current = correction.currentFields;
    final title = (current['title'] as String?)?.trim();
    final created = correction.createdAt;
    final pending = correction.status == 'pending';
    return DecoratedBox(
      key: ValueKey('admin-correction-${correction.id}'),
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title == null || title.isEmpty
                        ? correction.entityId
                        : title,
                    style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  [
                    kindLabel,
                    if (created != null)
                      AppFormats.current.formatDateTime(created.toLocal()),
                  ].join(' · '),
                  style: TextStyle(color: palette.textMuted, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            MetadataDiffPanel(
              title: 'Proposed changes',
              showOnlyDifferences: false,
              localHeader: 'Proposed',
              serverHeader: 'Core now',
              emptyText: current.isEmpty
                  ? 'The Core item no longer exists.'
                  : 'No fields.',
              entries: [
                for (final MapEntry(:key, :value)
                    in correction.proposedFields.entries)
                  MetadataDiffEntry(
                    label: fieldLabels[key] ?? key,
                    localValue: coreValueText(value),
                    serverValue: coreValueText(current[key]),
                  ),
              ],
            ),
            if (pending && correction.stale)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Core changed this item since it was proposed, so it '
                  'cannot be applied as it is. Reject it; the proposer can '
                  'send it again against the current values.',
                  key: const ValueKey('admin-correction-stale'),
                  style: TextStyle(color: palette.difference),
                ),
              ),
            if (pending)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: isActing ? null : onReject,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: isActing || correction.stale ? null : onApprove,
                    icon: isActing
                        ? const SizedBox.square(
                            dimension: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check, size: 16),
                    label: const Text('Apply to Core'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
