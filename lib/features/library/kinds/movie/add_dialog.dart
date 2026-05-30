import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog_theme.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_preview.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_shell.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_add_registry.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';

Future<LibraryAddDialogResult?> showMovieLibraryAddDialog(
  BuildContext context,
  LibraryAddDialogRequest request,
) {
  return showDialog<LibraryAddDialogResult>(
    context: context,
    builder: (context) => MovieLibraryAddDialog(request: request),
  );
}

class MovieLibraryAddDialog extends StatelessWidget {
  const MovieLibraryAddDialog({
    super.key,
    required this.request,
  });

  final LibraryAddDialogRequest request;

  @override
  Widget build(BuildContext context) {
    return LibraryAddDialog(
      type: request.type,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialBarcode: request.initialBarcode,
      headerBuilder: buildMovieAddHeader,
      modeBarBuilder: buildMovieAddModeBar,
      searchPaneBuilder: buildMovieAddSearchPane,
      manualPaneBuilder: buildMovieManualPane,
      previewPaneBuilder: buildMovieAddPreviewPane,
      bottomBarBuilder: buildMovieAddBottomBar,
    );
  }
}

Widget buildMovieManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) {
  return _MovieManualPane(request: request);
}

// Register the movie add dialog builders so the generic dialog can use them.
void registerMovieAddBuilders() {
  LibraryAddRegistry.registerHeaderBuilder(
    CatalogMediaKind.movie,
    buildMovieAddHeader,
  );
  LibraryAddRegistry.registerModeBarBuilder(
    CatalogMediaKind.movie,
    buildMovieAddModeBar,
  );
  LibraryAddRegistry.registerSearchBuilder(
    CatalogMediaKind.movie,
    buildMovieAddSearchPane,
  );
  LibraryAddRegistry.registerManualBuilder(
    CatalogMediaKind.movie,
    buildMovieManualPane,
  );
  LibraryAddRegistry.registerPreviewBuilder(
    CatalogMediaKind.movie,
    buildMovieAddPreviewPane,
  );
  LibraryAddRegistry.registerBottomBarBuilder(
    CatalogMediaKind.movie,
    buildMovieAddBottomBar,
  );
}

class _MovieManualPane extends StatelessWidget {
  const _MovieManualPane({required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final media = request.type.mediaFields;
    final release = request.type.releaseFields;
    final copyTypeLabel = ownedCopyTypeLabel(
      digitalPhysicalMediaFormatFlag(
        request.physicalFormatId,
        formats: request.physicalFormats,
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(left: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: palette.panelRaised,
                border: Border.all(color: palette.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          request.type.workspace.icon,
                          size: 20,
                          color: request.accent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manual movie setup',
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Set release basics here, then review format and collection details before saving.',
                                style: TextStyle(
                                  color: palette.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        LibraryAddResultBadge(request.defaultCondition,
                            accent: request.accent),
                        LibraryAddResultBadge(request.defaultGrade,
                            accent: request.accent),
                        if (request.defaultLocationLabel != null)
                          LibraryAddResultBadge(request.defaultLocationLabel!,
                              accent: request.accent),
                        if (request.defaultPurchaseDate != null)
                          LibraryAddResultBadge(
                            _formatDate(request.defaultPurchaseDate!),
                            accent: request.accent,
                          ),
                        if (copyTypeLabel != null)
                          LibraryAddResultBadge(copyTypeLabel,
                              accent: request.accent),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    controller: request.titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.movie_creation_outlined),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (copyTypeLabel != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Owned copies created from this draft will be saved as $copyTypeLabel.',
                      style: TextStyle(
                        color: palette.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: request.numberController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: media.numberLabel,
                            prefixIcon: const Icon(Icons.confirmation_number),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: request.yearController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Release year',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: request.publisherController,
                    decoration: InputDecoration(
                      labelText: media.publisherLabel,
                      prefixIcon: const Icon(Icons.apartment_outlined),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: request.variantController,
                          decoration: InputDecoration(
                            labelText: release.variantLabel,
                            prefixIcon: const Icon(Icons.album_outlined),
                          ),
                        ),
                      ),
                      if (request.physicalFormats.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: request.physicalFormatId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Physical format',
                              prefixIcon: Icon(Icons.disc_full_outlined),
                            ),
                            dropdownColor: palette.panelRaised,
                            borderRadius: kAppMenuBorderRadius,
                            items: [
                              const DropdownMenuItem<String>(
                                value: '',
                                child: Text('No specific format'),
                              ),
                              for (final format in request.physicalFormats)
                                DropdownMenuItem<String>(
                                  value: format.id,
                                  child: Text(format.label),
                                ),
                            ],
                            onChanged: request.onPhysicalFormatChanged,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: request.barcodeController,
                    decoration: InputDecoration(
                      labelText: release.barcodeLabel,
                      prefixIcon: const Icon(Icons.qr_code_2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: request.coverController,
                    decoration: const InputDecoration(
                      labelText: 'Poster / cover URL',
                      prefixIcon: Icon(Icons.image_outlined),
                    ),
                  ),
                  if (request.defaultTags?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Default tags',
                      style: TextStyle(
                        color: request.accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      request.defaultTags!,
                      style: TextStyle(
                        color: palette.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: request.isAdding ? null : request.onAddTrack,
                    style: libraryAddOutlinedButtonStyle(request.accent),
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
                    style: libraryAddOutlinedButtonStyle(request.accent),
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
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}