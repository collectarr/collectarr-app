import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_contents.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
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
    final family = disc.formatFamily ??
        MusicDiscFormatFamily.fromFormatName(disc.format);
    final isVinyl = family == MusicDiscFormatFamily.vinyl;
    final isCassette = family == MusicDiscFormatFamily.cassette;
    final isOptical = family == MusicDiscFormatFamily.cd ||
        family == MusicDiscFormatFamily.sacd ||
        family == MusicDiscFormatFamily.minidisc;

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
          width: wide ? 200 : double.infinity,
          child: LibraryManagedVocabularyField(
            label: 'Format',
            listName: MusicVocabularyIds.format.value,
            mediaKind: 'music',
            value: disc.format.isNotEmpty ? disc.format : null,
            builtIns: MusicVocabularies.format.builtIns,
            onChanged: (value) {
              disc.format = value ?? '';
              disc.formatFamily = MusicDiscFormatFamily.fromFormatName(value);
              _notify();
            },
          ),
        );
        final familyPicker = SizedBox(
          width: wide ? 160 : double.infinity,
          child: LibraryFormField(
            label: 'Family',
            child: DropdownButtonFormField<MusicDiscFormatFamily>(
              initialValue: family,
              isExpanded: true,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              items: [
                for (final item in MusicDiscFormatFamily.values)
                  DropdownMenuItem(
                    value: item,
                    child: Text(item.name.toUpperCase()),
                  ),
              ],
              onChanged: (val) {
                if (val != null) {
                  disc.formatFamily = val;
                  _notify();
                }
              },
            ),
          ),
        );
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              const SizedBox(height: 8),
              format,
              const SizedBox(height: 8),
              familyPicker,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const SizedBox(width: 12),
            format,
            const SizedBox(width: 12),
            familyPicker,
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

    final colorField = LibraryManagedVocabularyField(
      label: 'Color',
      listName: MusicVocabularyIds.vinylColor.value,
      mediaKind: 'music',
      value: disc.color.isNotEmpty ? disc.color : null,
      builtIns: MusicVocabularies.vinylColor.builtIns,
      onChanged: (value) {
        disc.color = value ?? '';
        _notify();
      },
    );

    final matrixA = MusicDiscTextField(
      id: 'manual-music-disc-matrix-a-${disc.id}',
      label: 'Matrix Side A',
      initialValue: disc.matrixNumberSideA,
      onChanged: (value) {
        disc.matrixNumberSideA = value;
        _notify();
      },
    );

    final matrixB = MusicDiscTextField(
      id: 'manual-music-disc-matrix-b-${disc.id}',
      label: 'Matrix Side B',
      initialValue: disc.matrixNumberSideB,
      onChanged: (value) {
        disc.matrixNumberSideB = value;
        _notify();
      },
    );

    final matrixRunout = MusicDiscTextField(
      id: 'manual-music-disc-matrix-${disc.id}',
      label: 'Matrix / Runout',
      initialValue: disc.matrixNumber,
      onChanged: (value) {
        disc.matrixNumber = value;
        _notify();
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        titleAndFormatRow,
        const SizedBox(height: 10),
        soundField,
        const SizedBox(height: 10),
        if (isVinyl) ...[
          LibraryFormGroup(
            title: 'Vinyl',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 600;
                final weight = LibraryFormField(
                  label: 'Weight (g)',
                  child: LibraryTextFormControl(
                    key: ValueKey('manual-vinyl-weight-${disc.id}'),
                    initialValue: disc.vinylWeightGrams?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      disc.vinylWeightGrams = int.tryParse(value);
                      _notify();
                    },
                  ),
                );
                final rpm = LibraryFormField(
                  label: 'RPM',
                  child: LibrarySegmentedField<String>(
                    value: disc.rpm ?? '33⅓',
                    options: const {
                      '33⅓': '33⅓',
                      '45': '45',
                      '78': '78',
                    },
                    onChanged: (value) {
                      disc.rpm = value;
                      _notify();
                    },
                  ),
                );
                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      colorField,
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
                    Expanded(flex: 3, child: colorField),
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
        if (isOptical) ...[
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 600;
              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    colorField,
                    const SizedBox(height: 8),
                    matrixRunout,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(flex: 2, child: colorField),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: matrixRunout),
                ],
              );
            },
          ),
        ],
        if (isVinyl) ...[
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
        if (isCassette) ...[
          colorField,
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
