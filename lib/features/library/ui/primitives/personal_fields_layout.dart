import 'package:flutter/material.dart';

/// Shared responsive layout for personal fields in Add and Edit forms.
final class LibraryPersonalFieldsLayout extends StatelessWidget {
  const LibraryPersonalFieldsLayout({
    super.key,
    required this.fields,
    this.fullWidthFields = const <Widget>[],
    this.history,
  });

  final List<Widget> fields;
  final List<Widget> fullWidthFields;
  final Widget? history;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 720
              ? 4
              : constraints.maxWidth >= 480
                  ? 2
                  : 1;
          final width = (constraints.maxWidth - 14 * (columns - 1)) / columns;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (fields.isNotEmpty)
                Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  children: [
                    for (final field in fields)
                      SizedBox(width: width, child: field),
                  ],
                ),
              for (var index = 0; index < fullWidthFields.length; index++) ...[
                if (fields.isNotEmpty || index > 0) const SizedBox(height: 14),
                fullWidthFields[index],
              ],
              if (history != null) ...[
                const SizedBox(height: 14),
                history!,
              ],
            ],
          );
        },
      );
}

/// Kind-owned composition receives semantic controls from the common renderer.
typedef LibraryPersonalLayoutBuilder = Widget Function(
    Map<String, Widget> fields, Widget? history);
