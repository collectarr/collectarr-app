import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MediaTrackingStatusField extends StatelessWidget {
  const MediaTrackingStatusField({
    super.key,
    required this.profile,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final MediaTrackingProfile profile;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      dropdownColor: kAppPanelRaised,
      borderRadius: kAppMenuBorderRadius,
      initialValue: profile.normalizeStorageValue(value),
      decoration: InputDecoration(
        labelText: label ?? '${profile.name} status',
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final option in profile.options)
          DropdownMenuItem(
            value: option.storageValue,
            child: Text(option.label),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
