import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog_theme.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_preview.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_shell.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_add_registry.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';

Future<LibraryAddDialogResult?> showComicLibraryAddDialog(
  BuildContext context,
  LibraryAddDialogRequest request,
) {
  return showDialog<LibraryAddDialogResult>(
    context: context,
    builder: (context) => ComicLibraryAddDialog(request: request),
  );
}

class ComicLibraryAddDialog extends StatelessWidget {
  const ComicLibraryAddDialog({
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
      headerBuilder: buildComicAddHeader,
      modeBarBuilder: buildComicAddModeBar,
      searchPaneBuilder: buildComicAddSearchPane,
      manualPaneBuilder: buildComicManualPane,
      previewPaneBuilder: buildComicAddPreviewPane,
      bottomBarBuilder: buildComicAddBottomBar,
    );
  }
}

Widget buildComicManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) {
  return _ComicManualPane(request: request);
}

// Register the comic add dialog builders so the generic dialog can use them.
void registerComicAddBuilders() {
  LibraryAddRegistry.registerHeaderBuilder(
    CatalogMediaKind.comic,
    buildComicAddHeader,
  );
  LibraryAddRegistry.registerModeBarBuilder(
    CatalogMediaKind.comic,
    buildComicAddModeBar,
  );
  LibraryAddRegistry.registerSearchBuilder(
    CatalogMediaKind.comic,
    buildComicAddSearchPane,
  );
  LibraryAddRegistry.registerManualBuilder(
    CatalogMediaKind.comic,
    buildComicManualPane,
  );
  // Provide comic-specific controllers so comics own their manual inputs.
  LibraryAddRegistry.registerManualKindSpecificFactory(
    CatalogMediaKind.comic,
    () => {
      'numberController': TextEditingController(),
      'publisherController': TextEditingController(),
      'yearController': TextEditingController(),
      'barcodeController': TextEditingController(),
      'variantController': TextEditingController(),
      'coverController': TextEditingController(),
      'editionTitleController': TextEditingController(),
      'releaseDateController': TextEditingController(),
      'pageCountController': TextEditingController(),
      'imprintController': TextEditingController(),
      'seriesGroupController': TextEditingController(),
      'countryController': TextEditingController(),
      'languageController': TextEditingController(),
      'ageRatingController': TextEditingController(),
      'genresEditController': TextEditingController(),
      'synopsisController': TextEditingController(),
      'tagsController': TextEditingController(),
      'creatorsController': TextEditingController(),
      'charactersController': TextEditingController(),
      'linksController': TextEditingController(),
      'rawOrSlabbedController': TextEditingController(),
      'gradingCompanyController': TextEditingController(),
      'graderNotesController': TextEditingController(),
      'signedByController': TextEditingController(),
      'labelTypeController': TextEditingController(),
      'certificationNumberController': TextEditingController(),
      'coverPriceController': TextEditingController(),
      'purchasePriceController': TextEditingController(),
      'purchaseDateController': TextEditingController(),
      'purchaseStoreController': TextEditingController(),
      'soldPriceController': TextEditingController(),
      'ownerLabelController': TextEditingController(),
    },
  );
  LibraryAddRegistry.registerPreviewBuilder(
    CatalogMediaKind.comic,
    buildComicAddPreviewPane,
  );
  LibraryAddRegistry.registerBottomBarBuilder(
    CatalogMediaKind.comic,
    buildComicAddBottomBar,
  );
}

class _ComicManualPane extends StatelessWidget {
  const _ComicManualPane({required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final copyTypeLabel = ownedCopyTypeLabel(
      digitalPhysicalMediaFormatFlag(
        request.physicalFormatId,
        formats: request.physicalFormats,
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border(left: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: palette.panel,
                border: Border.all(color: palette.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ManualKindHeader(
                      icon: request.type.workspace.icon,
                      accent: request.accent,
                      title: 'Manual comic issue',
                      subtitle:
                          'Use the core comic fields first, then apply your collection defaults when saving.',
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        const LibraryAddResultBadge('main'),
                        LibraryAddResultBadge(
                          copyTypeLabel ?? 'owned defaults',
                          accent: request.accent,
                        ),
                        if (request.defaultLocationLabel != null)
                          LibraryAddResultBadge(
                            request.defaultLocationLabel!,
                            accent: request.accent,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _ComicManualSection(
                    title: 'Main',
                    accent: request.accent,
                    child: Column(
                      children: [
                        _ComicManualResponsiveRow(
                          children: [
                            _ComicManualResponsiveItem(
                              flex: 3,
                              child: TextField(
                                controller: request.titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Series',
                                  prefixIcon: Icon(Icons.title),
                                ),
                              ),
                            ),
                            _ComicManualResponsiveItem(
                              child: TextField(
                                controller: request.numberController,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  labelText: 'Issue No.',
                                  prefixIcon:
                                      Icon(Icons.confirmation_number_outlined),
                                ),
                              ),
                            ),
                            _ComicManualResponsiveItem(
                              child: TextField(
                                controller: request.variantController,
                                decoration: const InputDecoration(
                                  labelText: 'Variant',
                                  prefixIcon:
                                      Icon(Icons.auto_awesome_motion_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _ComicManualResponsiveRow(
                          children: [
                            _ComicManualResponsiveItem(
                              flex: 2,
                              child: TextField(
                                controller: request.barcodeController,
                                decoration: const InputDecoration(
                                  labelText: 'Barcode',
                                  prefixIcon: Icon(Icons.qr_code_2),
                                ),
                              ),
                            ),
                            if (request.physicalFormats.isNotEmpty)
                              _ComicManualResponsiveItem(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  initialValue: request.physicalFormatId,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Format',
                                    prefixIcon: Icon(
                                      Icons.collections_bookmark_outlined,
                                    ),
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
                            _ComicManualResponsiveItem(
                              child: TextField(
                                controller: request.yearController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Cover Date (YYYY)',
                                  prefixIcon:
                                      Icon(Icons.calendar_today_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _ComicManualResponsiveRow(
                          children: [
                            _ComicManualResponsiveItem(
                              flex: 2,
                              child: TextField(
                                controller: request.publisherController,
                                decoration: const InputDecoration(
                                  labelText: 'Publisher',
                                  prefixIcon: Icon(Icons.business_outlined),
                                ),
                              ),
                            ),
                            _ComicManualResponsiveItem(
                              flex: 2,
                              child: TextField(
                                controller: request.coverController,
                                decoration: const InputDecoration(
                                  labelText: 'Cover image URL',
                                  prefixIcon: Icon(Icons.image_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ManualDefaultsCard(
                    accent: request.accent,
                    title: 'Collection defaults',
                    subtitle: copyTypeLabel == null
                        ? 'Owned copies will inherit your current comic defaults.'
                        : 'Owned copies will be saved as $copyTypeLabel.',
                    values: [
                      request.defaultCondition,
                      request.defaultGrade,
                      if (request.defaultLocationLabel != null)
                        request.defaultLocationLabel!,
                      if (request.defaultPurchaseDate != null)
                        _formatDate(request.defaultPurchaseDate!),
                      if (request.defaultTags?.trim().isNotEmpty == true)
                        'Tags: ${request.defaultTags!}',
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _ManualActionBar(request: request),
          ],
        ),
      ),
    );
  }
}

class _ManualKindHeader extends StatelessWidget {
  const _ManualKindHeader({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
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
    );
  }
}

class _ComicManualSection extends StatelessWidget {
  const _ComicManualSection({
    required this.title,
    required this.accent,
    required this.child,
  });

  final String title;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.canvas,
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: accent,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _ComicManualResponsiveRow extends StatelessWidget {
  const _ComicManualResponsiveRow({required this.children});

  final List<_ComicManualResponsiveItem> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isStacked = constraints.maxWidth < 780;
        if (isStacked) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index].child,
                if (index != children.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(
                flex: children[index].flex,
                child: children[index].child,
              ),
              if (index != children.length - 1) const SizedBox(width: 10),
            ],
          ],
        );
      },
    );
  }
}

class _ComicManualResponsiveItem {
  const _ComicManualResponsiveItem({
    required this.child,
    this.flex = 1,
  });

  final Widget child;
  final int flex;
}

class _ManualDefaultsCard extends StatelessWidget {
  const _ManualDefaultsCard({
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.values,
  });

  final Color accent;
  final String title;
  final String subtitle;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: palette.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final value in values)
                  LibraryAddResultBadge(value, accent: accent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualActionBar extends StatelessWidget {
  const _ManualActionBar({required this.request});

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
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}