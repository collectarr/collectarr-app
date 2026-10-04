import 'dart:async';

import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Music's local grading vocabulary field shared by Manual Add and Edit.
final class MusicGradeField extends ConsumerStatefulWidget {
  const MusicGradeField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  ConsumerState<MusicGradeField> createState() => _MusicGradeFieldState();
}

final class _MusicGradeFieldState extends ConsumerState<MusicGradeField> {
  List<String> _options = const ['Ungraded'];

  @override
  void initState() {
    super.initState();
    unawaited(_loadOptions());
  }

  Future<void> _loadOptions() async {
    final options = await loadSingleValuePickListOptions(
      ref.read(localDatabaseProvider),
      listName: MusicVocabularies.grade.key,
      mediaKind: 'music',
      builtInValues: MusicVocabularies.grade.builtIns,
      selectedValue: widget.value,
    );
    if (!mounted) return;
    setState(() => _options = options);
  }

  @override
  Widget build(BuildContext context) => LibraryDropdownPickField<String>(
        label: 'Grade',
        value: widget.value,
        options: [
          for (final value in _options)
            LibraryFieldOption(value: value, label: value),
          if (widget.value?.trim().isNotEmpty == true &&
              !_options.any((value) =>
                  value.toLowerCase() == widget.value!.trim().toLowerCase()))
            LibraryFieldOption(value: widget.value!, label: widget.value!),
        ],
        allowCustomValue: true,
        clearOptionLabel: 'Clear grade',
        onChanged: widget.onChanged,
      );
}
