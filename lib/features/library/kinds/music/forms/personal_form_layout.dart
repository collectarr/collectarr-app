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
  Widget pair(String first, String second) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: stack([first])),
          const SizedBox(width: 14),
          Expanded(child: stack([second])),
        ],
      );
  return LayoutBuilder(builder: (context, constraints) {
    final right =
        stack(['owner_label', 'rating', 'personal_notes'], trailing: history);
    final Widget body;
    if (constraints.maxWidth >= 900) {
      // Three columns as in the reference: purchase facts in two columns,
      // owner, rating, notes and plays in the third.
      body = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          flex: 2,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            pair('purchase_date', 'purchase_store'),
            pair('price_paid_cents', 'market_value_cents'),
            stack(['tags', 'last_cleaned_date', 'signed_by']),
          ]),
        ),
        const SizedBox(width: 14),
        Expanded(child: right),
      ]);
    } else {
      final left = stack([
        'purchase_date',
        'price_paid_cents',
        'purchase_store',
        'market_value_cents',
        'tags',
        'last_cleaned_date',
        'signed_by'
      ]);
      body = constraints.maxWidth >= 720
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: left),
              const SizedBox(width: 14),
              Expanded(child: right)
            ])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [left, right]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      body,
      const SizedBox(height: 12),
      LibraryFormGroup(
          title: 'Additional Personal Details',
          child: stack(['currency', 'grade'])),
    ]);
  });
}
