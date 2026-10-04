import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:flutter/material.dart';

Widget buildMovieResponsiveFields(List<Widget> children) {
  return LibraryEditDenseFields(
    wideColumns: 2,
    ultraWideColumns: 2,
    wideBreakpoint: 600,
    ultraWideBreakpoint: 600,
    children: children,
  );
}

Widget buildMovieField({
  required TextEditingController controller,
  required String label,
  String? Function(String?)? validator,
}) {
  return LibraryEditTextField(
    controller: controller,
    label: label,
    validator: validator,
  );
}
