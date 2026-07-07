part of 'video_edit_tabs.dart';

Widget _creditsTab({
  required String title,
  required String emptyMessage,
  required String addLabel,
  required Color accent,
  required List<EditableVideoCredit> credits,
  required VoidCallback onAdd,
}) {
  return EditTabShell(
    children: [
      EditSection(
        title: title,
        accent: accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (credits.isEmpty)
                EditSectionStateMessage(
                  message: emptyMessage,
                icon: Icons.person_outline,
              )
            else
              Column(
                children: [
                  for (final credit in credits)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: credit.nameController,
                              decoration: const InputDecoration(labelText: 'Name'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: credit.roleController,
                              decoration: const InputDecoration(labelText: 'Role'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(addLabel),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _responsiveFields(List<Widget> children) {
  return LibraryEditDenseFields(
    wideColumns: 2,
    ultraWideColumns: 2,
    wideBreakpoint: 600,
    ultraWideBreakpoint: 600,
    children: children,
  );
}

Widget _field({
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
