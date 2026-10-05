import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart';
import 'library_add_status_button.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/ui/library_action_footer.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryAddManualActionBar extends StatelessWidget {
  const LibraryAddManualActionBar({
    super.key,
    required this.request,
    required this.formKey,
    this.validateAdditionalFields,
  });

  final LibraryAddManualPaneRequest request;
  final GlobalKey<FormState> formKey;
  final String? Function(BuildContext context)? validateAdditionalFields;

  VoidCallback? _validatedAction(BuildContext context, VoidCallback action) =>
      request.isAdding
          ? null
          : () {
              if (validateAdditionalFields?.call(context) != null) return;
              if (!(formKey.currentState?.validate() ?? true)) return;
              action();
            };

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final actions = LayoutBuilder(
      builder: (context, constraints) {
        final buttons = [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _validatedAction(context, request.onPropose),
              style: OutlinedButton.styleFrom(
                foregroundColor: request.accent,
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.outbox_outlined, size: 18),
              label: const Text('Propose', overflow: TextOverflow.ellipsis),
            ),
          ),
          const SizedBox(width: 8),
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
          Expanded(
            child: LibraryAddStatusButton(
              status: libraryCollectionStatusFromValue(
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
