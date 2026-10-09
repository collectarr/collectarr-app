import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_format_presets.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_disc_text_field.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_pick_list_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_names_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_options_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_vocabulary_options_loader.dart';
import 'package:flutter/material.dart';

/// Form section holding physical, technical, and storage metadata for one disc.
class MusicDiscDetailsView extends StatefulWidget {
  const MusicDiscDetailsView({
    super.key,
    required this.disc,
    required this.draft,
    this.onChanged,
    this.discPersonalFieldBuilder,
  });

  final MusicDisc disc;
  final MusicAlbumEditDraft draft;
  final VoidCallback? onChanged;
  final Widget Function(MusicDisc disc, String label, String key)?
      discPersonalFieldBuilder;

  @override
  State<MusicDiscDetailsView> createState() => _MusicDiscDetailsViewState();
}

class _MusicDiscDetailsViewState extends State<MusicDiscDetailsView> {
  MusicDisc get disc => widget.disc;
  MusicAlbumEditDraft get draft => widget.draft;

  void _notify() {
    setState(() {});
    widget.onChanged?.call();
  }

  List<Map<String, dynamic>> _discDetails(LibraryEntryEditDraft entry) {
    final raw = entry.values['media'];
    return raw is List
        ? [
            for (final row in raw)
              if (row is Map && row['disc_id'] is String)
                Map<String, dynamic>.from(row),
          ]
        : <Map<String, dynamic>>[];
  }

  Widget _discPersonalField(MusicDisc disc, String label, String key) {
    final entry = LibraryEntryEditScope.maybeOf(context);
    final rows = entry == null ? <Map<String, dynamic>>[] : _discDetails(entry);
    final row =
        rows.where((row) => row['disc_id'] == disc.id.value).firstOrNull;
    if (widget.discPersonalFieldBuilder != null) {
      return widget.discPersonalFieldBuilder!(disc, label, key);
    }
    void save(String? value) {
      if (entry == null) return;
      final next = _discDetails(entry);
      final details =
          next.where((row) => row['disc_id'] == disc.id.value).firstOrNull;
      final normalized = value?.trim();
      if (details != null) {
        details[key] = normalized?.isEmpty == true ? null : normalized;
      } else {
        next.add({
          'disc_id': disc.id.value,
          key: normalized?.isEmpty == true ? null : normalized
        });
      }
      entry.set('media', next);
      if (key == 'storage_device') {
        final listName = MusicVocabularies.storageDevice.key;
        entry.vocabularyEdits.replaceValue(
          fieldId: 'disc:${disc.id.value}:$key',
          listName: listName,
          value: normalized,
          mediaKind: 'music',
        );
      }
      _notify();
    }

    if (key == 'storage_device') {
      return LibraryManagedVocabularyField(
        label: label,
        listName: MusicVocabularies.storageDevice.key,
        mediaKind: 'music',
        value: row?[key]?.toString(),
        enabled: entry != null,
        onChanged: save,
      );
    }
    return LibraryFormField(
      label: label,
      child: LibraryTextFormControl(
        key: ValueKey('${disc.id.value}:$key'),
        initialValue: row?[key]?.toString() ?? '',
        enabled: entry != null,
        onChanged: save,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final presetFamily = musicFormatPresetFamily(disc.format);
    final family = presetFamily ?? disc.formatFamily;
    final capabilities = family?.capabilities;
    final hasVinylControls = capabilities?.supportsVinylWeight == true ||
        capabilities?.supportsRpm == true;
    final hasSideMatrices = capabilities?.supportsSideMatrices == true;
    final hasGenericMatrix = capabilities?.supportsGenericMatrix == true;
    final hasColor = capabilities?.supportsColor == true;
    final isCustomFormat = presetFamily == null;

    final titleAndFormatRow = LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 600;
        final title = MusicDiscTextField(
          id: 'music-disc-title-${disc.id.value}',
          label: 'Disc Title',
          initialValue: disc.title ?? '',
          onChanged: (value) {
            draft.discList.updateDiscTitle(disc.id, value);
            widget.onChanged?.call();
          },
        );
        final format = SizedBox(
          width: wide ? 200 : double.infinity,
          child: LibraryManagedVocabularyField(
            label: 'Format',
            listName: MusicVocabularyIds.format.value,
            mediaKind: 'music',
            value: disc.format,
            builtIns: MusicVocabularies.format.builtIns,
            onChanged: (value) {
              final preset = musicFormatPresetFamily(value);
              draft.discList.updateDiscFormat(
                disc.id,
                value,
                formatFamily: preset,
                clearFormatFamily: preset == null,
              );
              _notify();
            },
          ),
        );
        final familyPicker = SizedBox(
          width: wide ? 160 : double.infinity,
          child: LibraryFormField(
            label: 'Family',
            child: DropdownButtonFormField<MusicDiscFormatFamily>(
              initialValue: disc.formatFamily,
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
                  draft.discList.updateDiscFormatFamily(disc.id, val);
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
              if (isCustomFormat) ...[
                const SizedBox(height: 8),
                familyPicker,
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const SizedBox(width: 12),
            format,
            if (isCustomFormat) ...[
              const SizedBox(width: 12),
              familyPicker,
            ],
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
          draft.discList.updateDiscSoundTypes(disc.id, values.toList());
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
      value: disc.color,
      builtIns: MusicVocabularies.vinylColor.builtIns,
      onChanged: (value) {
        draft.discList.updateDiscColor(disc.id, value);
        _notify();
      },
    );

    final matrixA = MusicDiscTextField(
      id: 'music-disc-matrix-a-${disc.id.value}',
      label: 'Matrix Side A',
      initialValue: disc.matrixNumberSideA ?? '',
      onChanged: (value) {
        draft.discList.updateDiscMatrixNumberSideA(disc.id, value);
        widget.onChanged?.call();
      },
    );

    final matrixB = MusicDiscTextField(
      id: 'music-disc-matrix-b-${disc.id.value}',
      label: 'Matrix Side B',
      initialValue: disc.matrixNumberSideB ?? '',
      onChanged: (value) {
        draft.discList.updateDiscMatrixNumberSideB(disc.id, value);
        widget.onChanged?.call();
      },
    );

    final matrixRunout = MusicDiscTextField(
      id: 'music-disc-matrix-${disc.id.value}',
      label: 'Matrix / Runout',
      initialValue: disc.matrixNumber ?? '',
      onChanged: (value) {
        draft.discList.updateDiscMatrixNumber(disc.id, value);
        widget.onChanged?.call();
      },
    );

    final storage =
        _discPersonalField(disc, 'Storage Device', 'storage_device');
    final slot = _discPersonalField(disc, 'Slot', 'storage_slot');
    final recordingDetails = LibraryFormGroup(
      title: 'Recording',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LibraryFormField(
            label: 'Recording Date',
            child: LibraryPartialDateInput(
              value: disc.recordingDate,
              onChanged: (value) {
                draft.discList.updateDiscRecordingDate(disc.id, value);
                _notify();
              },
            ),
          ),
          const SizedBox(height: 10),
          LibraryOrderedPickListField(
            label: 'Recording Locations',
            listName: MusicVocabularyIds.recordingLocation.value,
            mediaKind: 'music',
            loadOptions: (db) => MusicVocabularies.nameOptions(
              db,
              MusicVocabularyIds.recordingLocation.value,
            ),
            values: [
              for (final location in disc.recordingLocations)
                LibraryNamedValue(id: location, name: location),
            ],
            onChanged: (values) {
              draft.discList.updateDiscRecordingLocations(
                disc.id,
                values.map((value) => value.name).toList(),
              );
              _notify();
            },
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final live = LibraryFormField(
                label: 'Recording Type',
                child: LibrarySegmentedField<bool>(
                  value: disc.isLive ?? false,
                  options: const {false: 'Studio', true: 'Live'},
                  onChanged: (value) {
                    draft.discList.updateDiscIsLive(disc.id, value);
                    _notify();
                  },
                ),
              );
              final spars = LibraryManagedVocabularyField(
                label: 'SPARS Code',
                listName: MusicVocabularyIds.spars.value,
                mediaKind: 'music',
                value: disc.sparsCode,
                builtIns: MusicVocabularies.spars.builtIns,
                onChanged: (value) {
                  draft.discList.updateDiscSparsCode(disc.id, value);
                  _notify();
                },
              );
              if (constraints.maxWidth < 520) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [live, const SizedBox(height: 8), spars],
                );
              }
              return Row(
                children: [
                  Expanded(child: live),
                  const SizedBox(width: 12),
                  Expanded(child: spars),
                ],
              );
            },
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        titleAndFormatRow,
        const SizedBox(height: 10),
        soundField,
        const SizedBox(height: 10),
        if (hasVinylControls) ...[
          LibraryFormGroup(
            title: family == MusicDiscFormatFamily.vinyl
                ? 'Vinyl'
                : 'Technical Details',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 600;
                final weight = LibraryFormField(
                  label: 'Weight (g)',
                  child: LibraryTextFormControl(
                    key: ValueKey('vinyl-weight-${disc.id.value}'),
                    initialValue: disc.vinylWeightGrams?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      draft.discList
                          .updateDiscVinylWeightGrams(disc.id, parsed);
                      widget.onChanged?.call();
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
                      draft.discList.updateDiscRpm(disc.id, value);
                      _notify();
                    },
                  ),
                );
                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasColor) ...[
                        colorField,
                        const SizedBox(height: 8),
                      ],
                      weight,
                      const SizedBox(height: 8),
                      rpm,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasColor) ...[
                      Expanded(flex: 3, child: colorField),
                      const SizedBox(width: 10),
                    ],
                    Expanded(flex: 2, child: weight),
                    const SizedBox(width: 10),
                    Expanded(flex: 3, child: rpm),
                  ],
                );
              },
            ),
          ),
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
          const SizedBox(height: 10),
        ] else if (hasGenericMatrix) ...[
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 600;
              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasColor) ...[
                      colorField,
                      const SizedBox(height: 8),
                    ],
                    matrixRunout,
                  ],
                );
              }
              return Row(
                children: [
                  if (hasColor) ...[
                    Expanded(flex: 1, child: colorField),
                    const SizedBox(width: 12),
                  ],
                  Expanded(flex: 2, child: matrixRunout),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
        ],
        if (hasSideMatrices && !hasVinylControls) ...[
          matrixA,
          const SizedBox(height: 10),
          matrixB,
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 10),
        recordingDetails,
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 600;
            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  storage,
                  const SizedBox(height: 8),
                  slot,
                ],
              );
            }
            return Row(
              children: [
                Expanded(flex: 3, child: storage),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: slot),
              ],
            );
          },
        ),
      ],
    );
  }
}
