import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:flutter/material.dart';

/// Copy-owned condition, storage and matrix data, indexed to actual release
/// media rather than stored in release metadata.
final class MusicOwnedCopyMediaTab extends StatefulWidget {
  const MusicOwnedCopyMediaTab({
    super.key,
    required this.draft,
    required this.mediums,
    required this.accent,
  });

  final MusicOwnedEditDraft draft;
  final List<MusicMedium> mediums;
  final Color accent;

  @override
  State<MusicOwnedCopyMediaTab> createState() => _MusicOwnedCopyMediaTabState();
}

final class _MusicOwnedCopyMediaTabState extends State<MusicOwnedCopyMediaTab> {
  late final List<_MediumControllers> _controllers;

  @override
  void initState() {
    super.initState();
    final byNumber = {
      for (final details in widget.draft.media) details.mediumIndex: details,
    };
    final canonical = widget.mediums.map((medium) => medium.mediumNumber);
    final indexes = <int>{...canonical, ...byNumber.keys}.toList()..sort();
    _controllers = [
      for (final index in indexes)
        _MediumControllers(
          mediumIndex: index,
          mediumTitle: widget.mediums
              .where((medium) => medium.mediumNumber == index)
              .firstOrNull
              ?.title,
          details: byNumber[index],
        ),
    ];
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controllers.isEmpty) {
      return const Center(child: Text('This release has no media yet.'));
    }
    return EditTabShell(
      children: [
        for (final medium in _controllers)
          EditSection(
            title:
                'Disc ${medium.mediumIndex}${medium.mediumTitle?.trim().isNotEmpty == true ? ' · ${medium.mediumTitle}' : ''}',
            accent: widget.accent,
            child: Column(
              children: [
                TextFormField(
                  controller: medium.mediaCondition,
                  decoration: const InputDecoration(
                    labelText: 'Media condition',
                  ),
                  onChanged: (_) => _save(medium),
                ),
                TextFormField(
                  controller: medium.storageDevice,
                  decoration: const InputDecoration(
                    labelText: 'Storage device',
                  ),
                  onChanged: (_) => _save(medium),
                ),
                TextFormField(
                  controller: medium.storageSlot,
                  decoration: const InputDecoration(
                    labelText: 'Storage slot',
                  ),
                  onChanged: (_) => _save(medium),
                ),
                TextFormField(
                  controller: medium.matrixRunouts,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Matrix / runout numbers',
                    helperText: 'One side per line, for example: A: ABC-001-A',
                  ),
                  onChanged: (_) => _save(medium),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _save(_MediumControllers controllers) {
    widget.draft.updateMedium(controllers.toDetails());
  }
}

final class _MediumControllers {
  _MediumControllers({
    required this.mediumIndex,
    required this.mediumTitle,
    required MusicOwnedMediumDetails? details,
  })  : mediaCondition = TextEditingController(
          text: details?.mediaCondition ?? '',
        ),
        storageDevice = TextEditingController(
          text: details?.storageDevice ?? '',
        ),
        storageSlot = TextEditingController(text: details?.storageSlot ?? ''),
        matrixRunouts = TextEditingController(
          text: [
            for (final runout
                in details?.matrixRunouts ?? const <MusicMatrixRunout>[])
              '${runout.side}: ${runout.runoutText}',
          ].join('\n'),
        ),
        original = details;

  final int mediumIndex;
  final String? mediumTitle;
  final TextEditingController mediaCondition;
  final TextEditingController storageDevice;
  final TextEditingController storageSlot;
  final TextEditingController matrixRunouts;
  final MusicOwnedMediumDetails? original;

  MusicOwnedMediumDetails toDetails() {
    final runouts = <MusicMatrixRunout>[];
    for (final rawLine in matrixRunouts.text.split(RegExp(r'[\r\n]+'))) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      final separator = line.indexOf(':');
      final side = separator < 0 ? 'A' : line.substring(0, separator).trim();
      final value = separator < 0 ? line : line.substring(separator + 1).trim();
      if (value.isNotEmpty) {
        runouts.add(MusicMatrixRunout(side: side, runoutText: value));
      }
    }
    return MusicOwnedMediumDetails(
      mediumIndex: mediumIndex,
      mediaCondition: _nullable(mediaCondition.text),
      storageDevice: _nullable(storageDevice.text),
      storageSlot: _nullable(storageSlot.text),
      matrixRunouts: runouts,
    );
  }

  void dispose() {
    mediaCondition.dispose();
    storageDevice.dispose();
    storageSlot.dispose();
    matrixRunouts.dispose();
  }
}

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
