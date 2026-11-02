import 'package:shared_preferences/shared_preferences.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'mobile_method_picker.dart';
import 'package:collectarr_app/features/library/add/dialog.dart';
import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:flutter/material.dart';

Future<LibraryAddDialogResult?> showLibraryAddDialog({
  required BuildContext context,
  required LibraryKindRegistration type,
  Color? accent,
  String? initialQuery,
  String? initialIdentifier,
  bool startManually = false,
}) {
  final request = LibraryAddDialogRequest(
    type: type,
    accent: accent,
    initialQuery: initialQuery,
    initialIdentifier: initialIdentifier,
  );
  return _showDefaultLibraryAddDialog(context, request, startManually);
}

Future<LibraryAddDialogResult?> _showDefaultLibraryAddDialog(
  BuildContext context,
  LibraryAddDialogRequest request,
  bool startManually,
) async {
  MobileAddMethod? method;
  if (appPresentationPlatform.isNativeMobile &&
      !startManually &&
      (request.initialQuery?.isEmpty ?? true) &&
      (request.initialIdentifier?.isEmpty ?? true)) {
    final preferences = await SharedPreferences.getInstance();
    if (!context.mounted) return null;
    if (!(preferences.getBool('mobile.add.skipMethodPicker') ?? false)) {
      final capability = libraryAddForKind(request.type.kind);
      final searchLabel = libraryPresentationForKind(request.type.kind)
          .searchFieldLabels
          .addSearchTabLabel;
      final browseLabel = capability.search.browse?.label;
      final choice = await showMobileAddMethodPicker(context,
          pluralLabel: request.type.identity.pluralLabel,
          headerColor: request.type.identity.accent,
          canScanCover: capability.chrome.canScanCover,
          searchLabel: browseLabel == null
              ? 'Search by ${searchLabel.toLowerCase()}'
              : 'Search by ${browseLabel.toLowerCase()} / ${searchLabel.toLowerCase()}');
      if (choice == null || !context.mounted) return null;
      method = choice.method;
      if (choice.remember) {
        await preferences.setBool('mobile.add.skipMethodPicker', true);
      }
    }
  }
  if (!context.mounted) return null;
  if (appPresentationPlatform.isNativeMobile) {
    return Navigator.of(context, rootNavigator: true)
        .push<LibraryAddDialogResult>(
      MaterialPageRoute<LibraryAddDialogResult>(
        fullscreenDialog: true,
        builder: (context) => LibraryAddDialog(
          type: request.type,
          accent: request.accent,
          initialQuery: request.initialQuery,
          initialIdentifier: request.initialIdentifier,
          startManually: startManually,
          initialMobileMethod: method,
        ),
      ),
    );
  }
  return showAppDialog<LibraryAddDialogResult>(
    context: context,
    barrierDismissible: false,
    // Add Manually brings its own barrier; the Add dialog stays hidden.
    barrierColor: startManually ? Colors.transparent : kAppDialogBarrierColor,
    builder: (context) => LibraryAddDialog(
      type: request.type,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialIdentifier: request.initialIdentifier,
      startManually: startManually,
    ),
  );
}
