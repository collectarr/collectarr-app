import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/shell/library_add_dialog_theme.dart';
import 'package:collectarr_app/features/library/ui/library_action_footer.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryAddManualActionBar extends StatelessWidget {
  const LibraryAddManualActionBar({
    super.key,
    required this.request,
    required this.formKey,
  });

  final LibraryAddManualPaneRequest request;
  final GlobalKey<FormState> formKey;

  VoidCallback? _validatedAction(VoidCallback action) => request.isAdding
      ? null
      : () {
          if (formKey.currentState?.validate() ?? true) action();
        };

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final actions = LayoutBuilder(
      builder: (context, constraints) {
        final buttons = [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _validatedAction(request.onPropose),
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
              onPressed: _validatedAction(request.onAddTrack),
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
            child: OutlinedButton.icon(
              onPressed: _validatedAction(request.onAddWishlist),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.textPrimary,
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.star_outline, size: 18),
              label: Text(
                LibraryAddCopy.addToTargetLabel(
                  count: 1,
                  type: request.type,
                  target: LibraryAddTarget.wishlist,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: _validatedAction(request.onAddOwned),
              style: libraryAddFilledButtonStyle(request.accent),
              icon: request.isAdding
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.inventory_2_outlined, size: 18),
              label: Text(
                LibraryAddCopy.addToTargetLabel(
                  count: 1,
                  type: request.type,
                  target: LibraryAddTarget.owned,
                ),
                overflow: TextOverflow.ellipsis,
              ),
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
