import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_names_field.dart';
import 'package:flutter/material.dart';

/// Ordered Book names with optional sort names, shared by Add and Edit.
class BookPersonCreditsField extends StatefulWidget {
  const BookPersonCreditsField({
    super.key,
    required this.label,
    required this.role,
    required this.credits,
    required this.onChanged,
  });

  final String label;
  final String role;
  final List<BookCatalogCredit> credits;
  final ValueChanged<List<BookCatalogCredit>> onChanged;

  @override
  State<BookPersonCreditsField> createState() => _BookPersonCreditsFieldState();
}

class _BookPersonCreditsFieldState extends State<BookPersonCreditsField> {
  late List<BookCatalogCredit> _credits;

  @override
  void initState() {
    super.initState();
    _credits = List.of(widget.credits);
  }

  @override
  void didUpdateWidget(covariant BookPersonCreditsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.credits, widget.credits)) {
      _credits = List.of(widget.credits);
    }
  }

  String _identity(int index, BookCatalogCredit credit) =>
      credit.id ?? '${widget.role.toLowerCase()}-$index';

  @override
  Widget build(BuildContext context) => LibraryOrderedNamesField(
        label: widget.label,
        values: [
          for (var index = 0; index < _credits.length; index++)
            LibraryNamedValue(
              id: _identity(index, _credits[index]),
              name: _credits[index].name,
              sortName: _credits[index].sortName,
            ),
        ],
        onChanged: (values) {
          final previous = <String, BookCatalogCredit>{
            for (var index = 0; index < _credits.length; index++)
              _identity(index, _credits[index]): _credits[index],
          };
          final next = [
            for (var index = 0; index < values.length; index++)
              _toCredit(
                values[index],
                previous[values[index].id],
                index,
              ),
          ];
          setState(() => _credits = next);
          widget.onChanged(next);
        },
      );

  BookCatalogCredit _toCredit(
    LibraryNamedValue value,
    BookCatalogCredit? previous,
    int sequence,
  ) =>
      BookCatalogCredit(
        name: value.name,
        id: previous?.id ?? (previous == null ? value.id : null),
        artistId: previous?.artistId,
        personId: previous?.personId,
        creditedName: previous?.creditedName,
        imageUrl: previous?.imageUrl,
        instrument: previous?.instrument,
        joinPhrase: previous?.joinPhrase,
        role: widget.role,
        roleId: previous?.roleId,
        sequence: sequence,
        sortName: value.sortName,
      );
}
