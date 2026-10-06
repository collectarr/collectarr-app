import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_contents.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_disc_text_field.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_options_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_vocabulary_options_loader.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Wraps manual Add details with a sub-tab bar: General + one tab per disc.
class MusicAddManualDetailsPane extends StatefulWidget {
  const MusicAddManualDetailsPane({
    super.key,
    required this.draft,
    required this.request,
    required this.generalContent,
  });

  final MusicAddManualDraft draft;
  final LibraryAddManualPaneRequest request;
  final Widget generalContent;

  @override
  State<MusicAddManualDetailsPane> createState() =>
      _MusicAddManualDetailsPaneState();
}

class _MusicAddManualDetailsPaneState extends State<MusicAddManualDetailsPane> {
  int _selectedSubTabIndex = 0;

  MusicAddManualDraft get draft => widget.draft;

  void _notify() {
    setState(() {});
    widget.request.onManualDraftChanged?.call();
  }

  Future<void> _removeDisc(int discIndex) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AccentAlertDialog(
        title: Text('Remove Disc ${discIndex + 1}?'),
        content: const Text(
          'This removes this disc and any tracks entered for it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove disc'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    draft.discs.removeAt(discIndex);
    setState(() {
      _selectedSubTabIndex = 0;
    });
    _notify();
  }

  Widget _subTabButton(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(80, 32),
          foregroundColor: selected ? palette.textPrimary : palette.textMuted,
          backgroundColor: selected ? palette.surfaceBright : palette.surface,
          side: BorderSide(
            color: selected ? palette.accent : palette.divider,
            width: selected ? 1.5 : 1.0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _subTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _subTabButton(
                    context,
                    label: 'General',
                    selected: _selectedSubTabIndex == 0,
                    onPressed: () => setState(() => _selectedSubTabIndex = 0),
                  ),
                  for (var i = 0; i < draft.discs.length; i++) ...[
                    _subTabButton(
                      context,
                      label: (draft.discs[i].format.trim().isNotEmpty)
                          ? 'Disc ${i + 1} · ${draft.discs[i].format.trim()}'
                          : 'Disc ${i + 1}',
                      selected: _selectedSubTabIndex == i + 1,
                      onPressed: () =>
                          setState(() => _selectedSubTabIndex = i + 1),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_selectedSubTabIndex > 0 &&
              _selectedSubTabIndex <= draft.discs.length) ...[
            IconButton(
              tooltip: 'Remove Disc $_selectedSubTabIndex',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () => _removeDisc(_selectedSubTabIndex - 1),
            ),
            const SizedBox(width: 4),
          ],
          OutlinedButton.icon(
            onPressed: () {
              draft.discs.add(MusicAddManualDisc());
              setState(() {
                _selectedSubTabIndex = draft.discs.length;
              });
              _notify();
            },
            icon: const Icon(Icons.add, size: 15),
            label: const Text('Add Disc'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _discForm(MusicAddManualDisc disc, int discIndex) {
    final formatLower = disc.format.toLowerCase();
    final isVinyl = formatLower.contains('vinyl') ||
        formatLower == 'lp' ||
        formatLower.contains('7"') ||
        formatLower.contains('12"') ||
        formatLower.contains('10"');
    final isCassette =
        formatLower.contains('cassette') || formatLower.contains('tape');

    final titleAndFormatRow = LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 600;
        final title = MusicDiscTextField(
          id: 'manual-music-disc-title-${disc.id}',
          label: 'Disc Title',
          initialValue: disc.title,
          onChanged: (value) {
            disc.title = value;
            _notify();
          },
        );
        final format = SizedBox(
          width: wide ? 240 : double.infinity,
          child: LibraryManagedVocabularyField(
            label: 'Format',
            listName: MusicVocabularyIds.format.value,
            mediaKind: 'music',
            value: disc.format.isNotEmpty ? disc.format : null,
            builtIns: MusicVocabularies.format.builtIns,
            onChanged: (value) {
              disc.format = value ?? '';
              _notify();
            },
          ),
        );
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [title, const SizedBox(height: 8), format],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const SizedBox(width: 12),
            format,
          ],
        );
      },
    );

    final soundField = LibraryVocabularyOptionsLoader(
      listName: MusicVocabularyIds.soundType.value,
      mediaKind: 'music',
      builtIns: MusicVocabularies.soundType.builtIns,
      selected: disc.soundTypes,
      builder: (options) => LibraryMultiValuePickField<String>(
        label: 'Sound',
        value: disc.soundTypes.toSet(),
        options: [
          for (final option in options)
            LibraryFieldOption(value: option, label: option),
        ],
        onChanged: (values) {
          disc.soundTypes = values.toList();
          _notify();
        },
        onOpenPicker: ({
          required label,
          required selectedValues,
          required options,
          searchHint,
          customValueHint,
        }) =>
            showLibraryMultiValueOptionsDialog<String>(
          context: context,
          label: label,
          options: options,
          selectedValues: selectedValues,
        ),
      ),
    );

    final sparsField = LibraryManagedVocabularyField(
      label: 'SPARS',
      listName: MusicVocabularyIds.spars.value,
      mediaKind: 'music',
      value: disc.spars.isNotEmpty ? disc.spars : null,
      builtIns: MusicVocabularies.spars.builtIns,
      onChanged: (value) {
        disc.spars = value ?? '';
        _notify();
      },
    );

    final matrixA = MusicDiscTextField(
      id: 'manual-music-disc-matrix-a-${disc.id}',
      label: isVinyl ? 'Matrix No. Side A' : 'Matrix No. Side A / Runout',
      initialValue: disc.matrixNumberSideA,
      onChanged: (value) {
        disc.matrixNumberSideA = value;
        _notify();
      },
    );

    final matrixB = MusicDiscTextField(
      id: 'manual-music-disc-matrix-b-${disc.id}',
      label: 'Matrix No. Side B',
      initialValue: disc.matrixNumberSideB,
      onChanged: (value) {
        disc.matrixNumberSideB = value;
        _notify();
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        titleAndFormatRow,
        const SizedBox(height: 10),
        if (isVinyl) ...[
          LibraryFormGroup(
            title: 'Vinyl',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 600;
                final color = LibraryManagedVocabularyField(
                  label: 'Color',
                  listName: MusicVocabularyIds.vinylColor.value,
                  mediaKind: 'music',
                  value: disc.vinylColor.isNotEmpty ? disc.vinylColor : null,
                  builtIns: MusicVocabularies.vinylColor.builtIns,
                  onChanged: (value) {
                    disc.vinylColor = value ?? '';
                    _notify();
                  },
                );
                final weight = LibraryFormField(
                  label: 'Weight (g)',
                  child: LibraryTextFormControl(
                    key: ValueKey('manual-vinyl-weight-${disc.id}'),
                    initialValue: disc.vinylWeight,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      disc.vinylWeight = value;
                      _notify();
                    },
                  ),
                );
                final rpm = LibraryFormField(
                  label: 'RPM',
                  child: LibrarySegmentedField<int>(
                    value: disc.rpm ?? 0,
                    options: const {0: 'N/A', 33: '33', 45: '45', 78: '78'},
                    onChanged: (value) {
                      disc.rpm = value == 0 ? null : value;
                      _notify();
                    },
                  ),
                );
                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      color,
                      const SizedBox(height: 8),
                      weight,
                      const SizedBox(height: 8),
                      rpm,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: color),
                    const SizedBox(width: 10),
                    Expanded(flex: 2, child: weight),
                    const SizedBox(width: 10),
                    Expanded(flex: 3, child: rpm),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 600;
            if (!isVinyl && !isCassette) {
              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    soundField,
                    const SizedBox(height: 8),
                    sparsField,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: soundField),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: sparsField),
                ],
              );
            } else {
              return soundField;
            }
          },
        ),
        if (!isCassette) ...[
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 600;
              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    matrixA,
                    const SizedBox(height: 8),
                    matrixB,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: matrixA),
                  const SizedBox(width: 12),
                  Expanded(child: matrixB),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedSubTabIndex > draft.discs.length) {
      _selectedSubTabIndex = 0;
    }

    Widget activeContent() {
      if (_selectedSubTabIndex == 0 || draft.discs.isEmpty) {
        return widget.generalContent;
      }
      final discIndex = _selectedSubTabIndex - 1;
      if (discIndex < 0 || discIndex >= draft.discs.length) {
        return widget.generalContent;
      }
      return _discForm(draft.discs[discIndex], discIndex);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _subTabBar(context),
        activeContent(),
      ],
    );
  }
}
