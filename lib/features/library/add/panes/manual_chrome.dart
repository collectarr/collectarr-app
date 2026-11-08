import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/add/controllers/dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/target.dart';
import 'package:collectarr_app/features/library/config/dialog_tokens.dart';
import 'package:collectarr_app/features/library/ui/action_footer.dart';
import 'package:collectarr_app/features/library/ui/primitives/collection_status_field.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// What a kind's footer needs: the pane and a way to run an action only
/// once the form is valid.
@immutable
class LibraryAddManualFooterRequest {
  const LibraryAddManualFooterRequest({
    required this.request,
    required this.validated,
  });

  final LibraryAddManualPaneRequest request;
  final VoidCallback? Function(BuildContext context, VoidCallback action)
      validated;
}

String? _queryAsTitle(String query) => query;
String? _noInitialTitle(String query) => null;
String _plainTitle(LibraryAddManualPaneRequest request) =>
    'Add ${request.type.identity.singularLabel.toLowerCase()} manually';

/// What a kind's Add Manually dialog does around its form.
@immutable
class LibraryAddManualChrome {
  const LibraryAddManualChrome({
    this.title,
    this.initialTitle = _queryAsTitle,
    this.footer,
    this.extraTargets = const [LibraryAddTarget.track],
  });

  /// As in the reference: titled "Add game manually", starting empty rather
  /// than from the search text, with Cancel and Add buttons.
  const LibraryAddManualChrome.plain({
    this.extraTargets = const [LibraryAddTarget.track],
  })  : title = _plainTitle,
        initialTitle = _noInitialTitle,
        footer = LibraryAddPlainManualFooter.new;

  /// The dialog's title; null shows the entered title.
  final String Function(LibraryAddManualPaneRequest request)? title;

  /// The title a new draft starts from, null leaving the draft as it is.
  final String? Function(String query) initialTitle;

  /// Replaces the default footer of status button and extra targets.
  final Widget Function(LibraryAddManualFooterRequest request)? footer;

  /// Where else the dialog can add to, beside the collection.
  final List<LibraryAddTarget> extraTargets;
}

/// Cancel and Add as in the reference, which follows the Collection Status
/// chosen in the form.
class LibraryAddPlainManualFooter extends StatelessWidget {
  const LibraryAddPlainManualFooter(this.footer, {super.key});

  final LibraryAddManualFooterRequest footer;

  @override
  Widget build(BuildContext context) {
    final request = footer.request;
    final palette = appPalette(context);
    final wishList = libraryCollectionStatusFromValue(
            request.commonDraft?.collectionStatus) ==
        LibraryCollectionStatusScope.wishList;
    return LibraryActionFooter(
      backgroundColor: palette.toolbar,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(10),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        SizedBox(
          height: kLibraryDialogFooterButtonHeight,
          width: 100,
          child: OutlinedButton(
            key: const Key('library.manual.cancel'),
            style: dialogActionButtonStyle(context, width: 100)
                .copyWith(side: const WidgetStatePropertyAll(BorderSide.none)),
            onPressed:
                request.isAdding ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 5),
        SizedBox(
          height: kLibraryDialogFooterButtonHeight,
          width: 100,
          child: FilledButton(
            key: const Key('library.manual.add'),
            style: dialogActionButtonStyle(context, primary: true, width: 100),
            onPressed: footer.validated(
                context, wishList ? request.onAddWishlist : request.onAddEntry),
            child: Text(request.isAdding ? 'Adding...' : 'Add'),
          ),
        ),
      ]),
    );
  }
}
