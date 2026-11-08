import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_add_registry.dart';
import 'package:collectarr_app/features/library/ui/primitives/collection_status_field.dart';
import 'manual_chrome.dart';
import 'status_button.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/add/models/common_draft.dart';
import 'package:collectarr_app/features/library/add/controllers/dialog_requests.dart';
import 'package:collectarr_app/features/library/add/copy.dart';
import 'package:collectarr_app/features/library/add/models/target.dart';
import 'package:collectarr_app/features/library/ui/action_footer.dart';
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
    final manual = collectarrKindAdds[request.kind]?.manualChrome ??
        const LibraryAddManualChrome();
    final offersTrack = manual.extraTargets.contains(LibraryAddTarget.track);
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
            if (offersTrack)
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
    if (manual.footer case final footer?) {
      return footer(LibraryAddManualFooterRequest(
          request: request, validated: _validatedAction));
    }
    final actions = LayoutBuilder(
      builder: (context, constraints) {
        final buttons = [
          if (offersTrack) ...[
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
}
