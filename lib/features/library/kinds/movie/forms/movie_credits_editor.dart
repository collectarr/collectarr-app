import 'package:collectarr_app/features/library/kinds/movie/forms/movie_credit_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_named_detail_list.dart';
import 'package:flutter/material.dart';

/// Shared editable credit rows for Movie Manual Add and Edit.
class MovieCreditsEditor extends StatelessWidget {
  const MovieCreditsEditor({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.addLabel,
    required this.defaultRole,
    required this.accent,
    required this.credits,
    this.onChanged,
  });

  final String title;
  final String emptyMessage;
  final String addLabel;
  final String defaultRole;
  final Color accent;
  final List<EditableMovieCredit> credits;
  final VoidCallback? onChanged;

  void _notifyChanged() => onChanged?.call();

  @override
  Widget build(BuildContext context) => LibraryNamedDetailList(
        title: title,
        emptyMessage: emptyMessage,
        addLabel: addLabel,
        accent: accent,
        rows: () => [
          for (final credit in credits)
            LibraryNamedDetailControllers(
              identity: credit,
              name: credit.nameController,
              detail: credit.roleController,
            ),
        ],
        onAdd: () => credits.add(EditableMovieCredit.custom(role: defaultRole)),
        onRemove: (index) => credits.removeAt(index).dispose(),
        onReorder: (oldIndex, newIndex) {
          credits.insert(newIndex, credits.removeAt(oldIndex));
        },
        onChanged: _notifyChanged,
      );
}
