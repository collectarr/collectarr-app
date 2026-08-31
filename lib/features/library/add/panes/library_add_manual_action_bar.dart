import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/shell/library_add_dialog_theme.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryAddManualActionBar extends StatelessWidget {
  const LibraryAddManualActionBar({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: request.isAdding ? null : request.onAddTrack,
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
                onPressed: request.isAdding ? null : request.onAddWishlist,
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
                onPressed: request.isAdding ? null : request.onAddOwned,
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
          ],
        ),
      ),
    );
  }
}
