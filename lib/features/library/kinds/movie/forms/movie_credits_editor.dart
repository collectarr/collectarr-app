import 'package:collectarr_app/features/library/kinds/movie/forms/movie_credit_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:flutter/material.dart';

/// Shared editable credit rows for Movie Manual Add and Edit.
class MovieCreditsEditor extends StatelessWidget {
  const MovieCreditsEditor({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.addLabel,
    required this.defaultRole,
    required this.credits,
    this.onChanged,
  });

  final String title;
  final String emptyMessage;
  final String addLabel;
  final String defaultRole;
  final List<EditableMovieCredit> credits;
  final VoidCallback? onChanged;

  void _notifyChanged() => onChanged?.call();

  @override
  Widget build(BuildContext context) => StatefulBuilder(
        builder: (context, setState) => LibraryFormGroup(
          title: title,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (credits.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    emptyMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: credits.length,
                  onReorderItem: (oldIndex, newIndex) {
                    credits.insert(newIndex, credits.removeAt(oldIndex));
                    setState(() {});
                    _notifyChanged();
                  },
                  itemBuilder: (context, index) {
                    final credit = credits[index];
                    return Padding(
                      key: ObjectKey(credit),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReorderableDragStartListener(
                            index: index,
                            child: const SizedBox(
                              height: 40,
                              child: Icon(Icons.drag_indicator, size: 18),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: LibraryFormField(
                              label: 'Name',
                              child: LibraryTextFormControl(
                                controller: credit.nameController,
                                onChanged: (_) => _notifyChanged(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LibraryFormField(
                              label: 'Role',
                              child: LibraryTextFormControl(
                                controller: credit.roleController,
                                onChanged: (_) => _notifyChanged(),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove credit',
                            onPressed: () {
                              credits.removeAt(index).dispose();
                              setState(() {});
                              _notifyChanged();
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () {
                    credits.add(EditableMovieCredit.custom(role: defaultRole));
                    setState(() {});
                    _notifyChanged();
                  },
                  icon: const Icon(Icons.add),
                  label: Text(addLabel),
                ),
              ),
            ],
          ),
        ),
      );
}
