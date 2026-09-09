import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';
import 'package:collectarr_app/features/library/detail/metadata_override_form.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MetadataCorrectionsSection extends ConsumerWidget {
  const MetadataCorrectionsSection({
    super.key,
    required this.targetRef,
    required this.accent,
  });

  final CatalogEntityRef targetRef;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overrides = ref.watch(metadataOverridesByItemProvider)[targetRef] ??
        const <UserMetadataOverride>[];
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: appPalette(context).surfaceSubtle,
        border: Border.all(color: accent.withValues(alpha: 0.33)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Metadata corrections',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  color: accent,
                  tooltip: 'Add correction',
                  onPressed: () => _showAddDialog(context, ref),
                ),
              ],
            ),
            if (overrides.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'No corrections - tap + to override a field',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.textMuted,
                      ),
                ),
              ),
            for (final override in overrides)
              _OverrideTile(entry: override, accent: accent),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final contributor = libraryAdminContributorForKind(targetRef.mediaKind);
    final fields = [
      MetadataOverrideFieldOption(
        id: MetadataFieldId(kind: targetRef.mediaKind, value: 'title'),
        label: 'Title',
      ),
      for (final field
          in contributor?.proposalFields ?? const <LibraryAdminProposalField>[])
        MetadataOverrideFieldOption(
          id: MetadataFieldId(kind: targetRef.mediaKind, value: field.key),
          label: field.label,
        ),
    ];
    final result = await showDialog<MetadataOverrideFormResult>(
      context: context,
      builder: (_) => MetadataOverrideFormDialog(
        accent: accent,
        fields: fields,
      ),
    );
    if (result == null || !context.mounted) {
      return;
    }
    await ref.read(metadataOverrideMutationsProvider).setMetadataOverride(
          targetRef,
          fieldId: result.fieldId,
          overrideValue: result.overrideValue,
          originalValue: result.originalValue,
        );
  }
}

String _humanFieldPath(MetadataFieldId fieldId) {
  return fieldId.value.replaceAll('_', ' ').replaceAll('.', ' > ');
}

class _OverrideTile extends ConsumerWidget {
  const _OverrideTile({required this.entry, required this.accent});

  final UserMetadataOverride entry;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: palette.surfaceSubtle.withValues(alpha: 0.82),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: accent.withValues(alpha: 0.15)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onLongPress: () => _confirmDelete(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _humanFieldPath(entry.fieldId),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _DiffColumn(
                        label: 'Original',
                        value: entry.originalValue ?? '-',
                        color: palette.textMuted,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 14, color: accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DiffColumn(
                        label: 'Corrected',
                        value: entry.overrideValue,
                        color: palette.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Override'),
        content: Text(
          'Revert "${_humanFieldPath(entry.fieldId)}" back to standard metadata?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref
          .read(metadataOverrideMutationsProvider)
          .removeMetadataOverride(entry);
    }
  }
}

class _DiffColumn extends StatelessWidget {
  const _DiffColumn({
    required this.label,
    required this.value,
    required this.color,
    this.decoration,
  });

  final String label;
  final String value;
  final Color color;
  final TextDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.libraryMicro.copyWith(
                color: palette.textMuted,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                decoration: decoration,
              ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
