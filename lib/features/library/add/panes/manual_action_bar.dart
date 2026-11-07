import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_add_registry.dart';
import 'package:collectarr_app/features/library/ui/primitives/collection_status_field.dart';
import 'status_button.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/add/models/common_draft.dart';
import 'package:collectarr_app/features/library/add/controllers/dialog_requests.dart';
import 'package:collectarr_app/features/library/add/copy.dart';
import 'package:collectarr_app/features/library/add/models/target.dart';
import 'package:collectarr_app/features/library/config/dialog_tokens.dart';
import 'package:collectarr_app/features/library/ui/action_footer.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryAddManualActionBar extends StatelessWidget {
  const LibraryAddManualActionBar({
    super.key,
    required this.request,
    required this.formKey,
    this.validateAdditionalFields,
    this.nativeHeader = false,
  });

  final LibraryAddManualPaneRequest request;
  final bool nativeHeader;
  final GlobalKey<FormState> formKey;
  final String? Function(BuildContext context)? validateAdditionalFields;

  VoidCallback? _validatedAction(BuildContext context, VoidCallback action) =>
      request.isAdding
          ? null
          : () {
              // The form first, so its errors show even when another tab's
              // check also stops the action.
              final formValid = formKey.currentState?.validate() ?? true;
              if (validateAdditionalFields?.call(context) != null) return;
              if (!formValid) return;
              action();
            };

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    if (nativeHeader) {
      final wishList = libraryCollectionStatusFromValue(
              request.commonDraft?.collectionStatus) ==
          LibraryCollectionStatusScope.wishList;
      return Row(mainAxisSize: MainAxisSize.min, children: [
        TextButton(
          key: const Key('library.mobile-manual.add'),
          style: TextButton.styleFrom(
              foregroundColor: Colors.white, minimumSize: const Size(64, 48)),
          onPressed: _validatedAction(
              context, wishList ? request.onAddWishlist : request.onAddEntry),
          child: Text(request.isAdding ? 'Adding?' : 'Add'),
        ),
        PopupMenuButton<VoidCallback>(
          tooltip: 'More Add actions',
          enabled: !request.isAdding,
          onSelected: (action) => _validatedAction(context, action)?.call(),
          itemBuilder: (_) => [
            if (collectarrKindAdds[request.kind]?.chrome.supportsTracking ??
                false)
              PopupMenuItem(
                  value: request.onAddTrack,
                  child: Text(LibraryAddCopy.addToTargetLabel(
                      count: 1,
                      type: request.type,
                      target: LibraryAddTarget.track))),
          ],
        ),
      ]);
    }
    if (collectarrKindAdds[request.kind]?.chrome.plainManualAdd ?? false) {
      return _plainFooter(context);
    }
    final actions = LayoutBuilder(
      builder: (context, constraints) {
        final buttons = [
          if (collectarrKindAdds[request.kind]?.chrome.supportsTracking ??
              false) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _validatedAction(context, request.onAddTrack),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.textPrimary,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: Text(
                  LibraryAddCopy.addToTargetLabel(
                    count: 1,
                    type: request.type,
                    target: LibraryAddTarget.track,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: LibraryAddStatusButton(
              collectionStatus: libraryCollectionStatusFromValue(
                  request.commonDraft?.collectionStatus),
              isBusy: request.isAdding,
              onAdd: _validatedAction(
                context,
                libraryCollectionStatusFromValue(
                            request.commonDraft?.collectionStatus) ==
                        LibraryCollectionStatusScope.wishList
                    ? request.onAddWishlist
                    : request.onAddEntry,
              ),
              onStatusChanged: request.onCommonDraftChanged == null
                  ? null
                  : (status) {
                      request.onCommonDraftChanged!(
                          (request.commonDraft ?? const LibraryAddCommonDraft())
                              .copyWith(
                        collectionStatus: libraryCollectionStatusValue(status),
                      ));
                    },
            ),
          ),
        ];

        if (constraints.maxWidth >= 660) {
          return Row(children: buttons);
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 660,
            child: Row(children: buttons),
          ),
        );
      },
    );

    return LibraryActionFooter(
      backgroundColor: palette.toolbar,
      borderColor: palette.divider,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: actions,
    );
  }

  /// Cancel and Add as in the reference, which follows the Collection Status
  /// chosen in the form.
  Widget _plainFooter(BuildContext context) {
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
            onPressed: _validatedAction(
                context, wishList ? request.onAddWishlist : request.onAddEntry),
            child: Text(request.isAdding ? 'Adding...' : 'Add'),
          ),
        ),
      ]),
    );
  }
}
