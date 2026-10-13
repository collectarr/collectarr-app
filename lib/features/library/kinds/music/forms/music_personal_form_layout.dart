import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:flutter/material.dart';

/// Personal composition shared by Music Add/Edit; currency and grade are App extras.
Widget musicPersonalFormLayout(Map<String, Widget> fields, Widget? history) {
  Widget stack(List<String> keys, {Widget? trailing}) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final key in keys)
            if (fields.containsKey(key)) ...[
              fields[key]!,
              const SizedBox(height: 12),
            ],
          if (trailing != null) trailing,
        ],
      );
  return LayoutBuilder(builder: (context, constraints) {
    final left = stack([
      'purchase_date',
      'price_paid_cents',
      'purchase_store',
      'market_value_cents',
      'tags',
      'last_cleaned_date',
      'signed_by'
    ]);
    final right =
        stack(['owner_label', 'rating', 'personal_notes'], trailing: history);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (constraints.maxWidth >= 720)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: left),
          const SizedBox(width: 14),
          Expanded(child: right)
        ])
      else ...[left, right],
      const SizedBox(height: 12),
      LibraryFormGroup(
          title: 'Additional Personal Details',
          child: stack(['currency', 'grade'])),
    ]);
  });
}
