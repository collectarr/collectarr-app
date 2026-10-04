import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/shared/video/library_video_credits_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_models.dart';
import 'package:flutter/material.dart';

Widget buildTvCreditsTab({
  required String title,
  required String emptyMessage,
  required String addLabel,
  required Color accent,
  required List<EditableTvCredit> credits,
  required VoidCallback onAdd,
  required VoidCallback onChanged,
}) {
  return LibraryVideoCreditsSection(
    title: title,
    emptyMessage: emptyMessage,
    addLabel: addLabel,
    accent: accent,
    credits: [
      for (final credit in credits)
        LibraryVideoCreditControllers(
          identity: credit,
          name: credit.nameController,
          role: credit.roleController,
        ),
    ],
    onAdd: onAdd,
    onChanged: onChanged,
  );
}

Widget buildTvResponsiveFields(List<Widget> children) {
  return LibraryEditDenseFields(
    wideColumns: 2,
    ultraWideColumns: 2,
    wideBreakpoint: 600,
    ultraWideBreakpoint: 600,
    children: children,
  );
}

Widget buildTvField({
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
