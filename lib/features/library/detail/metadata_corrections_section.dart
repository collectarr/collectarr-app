import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MetadataCorrectionsSection extends ConsumerWidget {
  const MetadataCorrectionsSection({
    super.key,
    required this.itemId,
    required this.accent,
  });

  final String itemId;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overrides = ref.watch(metadataOverridesByItemProvider)[itemId] ??
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
    final result = await showDialog<_OverrideFormResult>(
      context: context,
      builder: (_) => _OverrideFormDialog(accent: accent),
    );
    if (result == null || !context.mounted) {
      return;
    }
    await ref.read(collectionMutationsProvider).setMetadataOverride(
          itemId,
          fieldPath: result.fieldPath,
          overrideValue: result.overrideValue,
          originalValue: result.originalValue,
        );
  }
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
                  _humanFieldPath(entry.fieldPath),
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
      builder: (ctx) => AccentAlertDialog(
        title: const Text('Remove correction?'),
        content: Text(
          'This will restore the original value for '
          '"${_humanFieldPath(entry.fieldPath)}".',
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
      await ref.read(collectionMutationsProvider).removeMetadataOverride(entry);
    }
  }

  static String _humanFieldPath(String path) {
    return path.replaceAll('_', ' ').replaceAll('.', ' > ');
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
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: palette.textMuted,
                fontSize: 10,
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

class _OverrideFormResult {
  const _OverrideFormResult({
    required this.fieldPath,
    required this.overrideValue,
    this.originalValue,
  });

  final String fieldPath;
  final String overrideValue;
  final String? originalValue;
}

class _OverrideFormDialog extends StatefulWidget {
  const _OverrideFormDialog({required this.accent});

  final Color accent;

  @override
  State<_OverrideFormDialog> createState() => _OverrideFormDialogState();
}

class _OverrideFormDialogState extends State<_OverrideFormDialog> {
  static const _commonFields = [
    'title',
    'synopsis',
    'publisher',
    'release_year',
    'barcode',
    'variant',
    'edition_title',
    'cover_image_url',
    'item_number',
  ];

  String? _selectedField;
  final _customFieldController = TextEditingController();
  final _originalController = TextEditingController();
  final _overrideController = TextEditingController();

  String get _fieldPath => _selectedField ?? _customFieldController.text.trim();

  bool get _isValid =>
      _fieldPath.isNotEmpty && _overrideController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _customFieldController.dispose();
    _originalController.dispose();
    _overrideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      titlePadding: EdgeInsets.zero,
      title: AccentDialogHeader(
        title: 'Add metadata correction',
        accent: widget.accent,
        icon: Icons.tune,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedField,
              decoration: const InputDecoration(labelText: 'Field'),
              items: [
                for (final field in _commonFields)
                  DropdownMenuItem(
                    value: field,
                    child: Text(field.replaceAll('_', ' ')),
                  ),
                const DropdownMenuItem(value: null, child: Text('Custom...')),
              ],
              onChanged: (value) => setState(() => _selectedField = value),
            ),
            if (_selectedField == null) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _customFieldController,
                decoration: const InputDecoration(
                  labelText: 'Custom field path',
                  hintText: 'e.g. edition.publisher',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _originalController,
              decoration: const InputDecoration(
                labelText: 'Original value (optional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _overrideController,
              decoration: const InputDecoration(
                labelText: 'Corrected value',
              ),
              maxLines: 2,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        DialogActionButtons.cancel(
          onPressed: () => Navigator.pop(context),
        ),
        DialogActionButtons.save(
          onPressed: _isValid
              ? () => Navigator.pop(
                    context,
                    _OverrideFormResult(
                      fieldPath: _fieldPath,
                      overrideValue: _overrideController.text.trim(),
                      originalValue: _originalController.text.trim().isEmpty
                          ? null
                          : _originalController.text.trim(),
                    ),
                  )
              : null,
        ),
      ],
    );
  }
}
