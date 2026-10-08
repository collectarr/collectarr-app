import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec_renderer.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:flutter/material.dart';

/// Shared Details pane for Music; physical metadata belongs to discs.
class MusicDetailsFormPane<TDraft> extends StatelessWidget {
  const MusicDetailsFormPane(
      {super.key,
      required this.draft,
      required this.values,
      required this.packageCondition,
      required this.mediaCondition,
      this.onChanged,
      this.onVocabularyValueChanged,
      this.onVocabularyValuesChanged});
  final TDraft draft;
  final MusicAlbumValuesReader<TDraft> values;
  final Widget packageCondition;
  final Widget mediaCondition;
  final VoidCallback? onChanged;
  final LibraryVocabularyValueChanged? onVocabularyValueChanged;
  final LibraryVocabularyValuesChanged? onVocabularyValuesChanged;
  Widget _fields(List<String> ids) => LibraryFieldSpecRenderer<TDraft>.embedded(
        draft: draft,
        mediaKind: 'music',
        onChanged: onChanged,
        sectionSpacing: 0,
        onVocabularyValueChanged: onVocabularyValueChanged,
        onVocabularyValuesChanged: onVocabularyValuesChanged,
        schema: LibraryFormSchema(sections: [
          LibraryFormSectionSpec(
            id: ids.join('-'),
            label: '',
            maxColumns: 1,
            fields:
                musicAlbumFields<TDraft>(values: values, include: ids.toSet()),
          )
        ]),
      );
  Widget _stack(List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            children[i],
          ],
        ],
      );
  @override
  Widget build(BuildContext context) {
    final left = _stack([
      LibraryFormGroup(
          title: 'Packaging',
          child: _stack([
            _fields(['packaging']),
            packageCondition,
            mediaCondition,
          ])),
      _fields(['studios']),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _fields(['country'])),
        const SizedBox(width: 14),
        Expanded(child: _fields(['is_live'])),
      ]),
    ]);
    final right = _stack([
      _fields(['extra', 'spars_code', 'box_set']),
    ]);
    return LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= 720
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: left),
                const SizedBox(width: 14),
                Expanded(child: right)
              ])
            : _stack([left, right]));
  }
}
