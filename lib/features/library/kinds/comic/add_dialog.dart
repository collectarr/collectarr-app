import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog_theme.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      manualPaneBuilder: buildComicManualPane,
    );
  }
}

Widget buildComicManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) {
  return _ComicManualPane(request: request);
}

class _ComicManualPane extends StatelessWidget {
  const _ComicManualPane({required this.request});

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
        color: palette.panelRaised,
        border: Border(left: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.canvas,
                  border: Border.all(color: palette.divider),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _ManualKindHeader(
                      icon: request.type.workspace.icon,
                      accent: request.accent,
                      title: 'Manual comic issue',
                      subtitle:
                          'Capture issue identity here, then review grading and ownership before saving.',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: request.titleController,
                      decoration: const InputDecoration(
                        labelText: 'Series / Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                              labelText: 'Cover year',
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
                        prefixIcon: const Icon(Icons.business_outlined),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: request.variantController,
                      decoration: InputDecoration(
                        labelText: release.variantLabel,
                        prefixIcon:
                            const Icon(Icons.auto_awesome_motion_outlined),
                      ),
                    ),
                    if (request.physicalFormats.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: request.physicalFormatId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Physical format',
                          prefixIcon: Icon(Icons.collections_bookmark_outlined),
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
                    ],
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
                        labelText: 'Cover image URL',
                        prefixIcon: Icon(Icons.image_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
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