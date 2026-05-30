import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_panel.dart';
import 'package:flutter/material.dart';

String? _buildComicSynopsis(String? summary, String? description) {
  final normalizedSummary = emptyToNull(summary ?? '');
  final normalizedDescription = emptyToNull(description ?? '');
  if (normalizedSummary != null && normalizedDescription != null) {
    return '$normalizedSummary\n\n$normalizedDescription';
  }
  return normalizedDescription ?? normalizedSummary;
}

Widget buildComicLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return ComicLibraryEditDialog(request: request);
}

class ComicLibraryEditDialog extends StatefulWidget {
  const ComicLibraryEditDialog({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<ComicLibraryEditDialog> createState() => _ComicLibraryEditDialogState();
}

class _ComicLibraryEditDialogState extends State<ComicLibraryEditDialog> {
  final _panelKey = GlobalKey<ComicEditPanelState>();
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    final map = _panelKey.currentState?.toMap();
    if (map == null) {
      Navigator.of(context).pop(null);
      return;
    }

    final parsedGenres = ((map['genres'] as String?) ?? '')
        .split(',')
        .map((genre) => genre.trim())
        .where((genre) => genre.isNotEmpty)
        .toList();
    final parsedStoryArcs = ((map['storyArcs'] as String?) ?? '')
        .split(',')
        .map((storyArc) => storyArc.trim())
        .where((storyArc) => storyArc.isNotEmpty)
        .toList();
    final parsedCrossover = emptyToNull(map['crossover'] ?? '');
    final parsedSummary = emptyToNull(map['summary'] ?? '');
    final parsedDescription = emptyToNull(map['description'] ?? '');
    final parsedReleaseDate = parseDate(map['releaseDate'] ?? '');
    final parsedCoverDate = parseDate(map['coverDate'] ?? '');
    final seriesTitle = emptyToNull(map['series'] ?? '');
    final updatedPublishing = CatalogPublishingDetails(
      pageCount: parseInt(map['pages'] as String? ?? ''),
      coverPriceCents: widget.request.item.publishing?.coverPriceCents,
      currency: widget.request.item.publishing?.currency,
      imprint: emptyToNull(map['imprint'] ?? ''),
      subtitle: widget.request.item.publishing?.subtitle,
      seriesGroup: emptyToNull(map['seriesGroup'] ?? ''),
    );

    final updatedCreators =
        ((map['creators'] as List<dynamic>?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .where(
              (creator) =>
                  emptyToNull(creator['name']?.toString() ?? '') != null,
            )
            .map((creator) {
              final normalized = <String, dynamic>{
                ...creator,
                'name': creator['name']?.toString() ?? '',
                'role': creator['role']?.toString() ?? '',
              };
              normalized.removeWhere(
                (key, value) =>
                    value == null || (value is String && value.trim().isEmpty),
              );
              return normalized;
            })
            .toList();
    final updatedCharacters =
        ((map['characters'] as List<dynamic>?) ?? const [])
            .map((character) => character.toString().trim())
            .where((character) => character.isNotEmpty)
            .toList();
    final updatedCharacterDetails =
        ((map['characterDetails'] as List<dynamic>?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .where(
              (character) =>
                  emptyToNull(character['name']?.toString() ?? '') != null,
            )
            .map((character) {
              final normalized = <String, dynamic>{
                ...character,
                'name': character['name']?.toString() ?? '',
              };
              normalized.removeWhere(
                (key, value) =>
                    value == null || (value is String && value.trim().isEmpty),
              );
              return normalized;
            })
            .toList();
    final updatedLinks = ((map['links'] as List<dynamic>?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (link) => TrailerLink(
            url: link['url']?.toString().trim() ?? '',
            title: emptyToNull(link['title']?.toString() ?? ''),
            isAutomatic: false,
          ),
        )
        .where((link) => link.url.isNotEmpty)
        .toList();

    final updatedItem = widget.request.item.copyWith(
      title: emptyToNull(map['title'] ?? '') ?? widget.request.item.title,
      titleExtension: emptyToNull(map['subtitle'] ?? ''),
      itemNumber: emptyToNull(map['issueNumber'] ?? ''),
      synopsis: _buildComicSynopsis(
        map['summary'] as String?,
        map['description'] as String?,
      ),
      crossover: parsedCrossover,
      plotSummary: parsedSummary,
      plotDescription: parsedDescription,
      coverImageUrl: emptyToNull(map['coverUrl'] ?? ''),
      thumbnailImageUrl: emptyToNull(map['coverUrl'] ?? ''),
      editionTitle: emptyToNull(map['variantDescription'] ?? ''),
      physicalFormatLabel: emptyToNull(map['format'] ?? ''),
      barcode: emptyToNull(map['barcode'] ?? ''),
      variant: emptyToNull(map['variant'] ?? ''),
      series: seriesTitle == null && widget.request.item.series == null
          ? null
          : CatalogSeriesDetails(
              seriesId: widget.request.item.series?.seriesId,
              seriesTitle: seriesTitle,
              volumeName: widget.request.item.series?.volumeName,
              volumeNumber: widget.request.item.series?.volumeNumber,
              volumeStartYear: widget.request.item.series?.volumeStartYear,
              seasonNumber: widget.request.item.series?.seasonNumber,
              episodeNumber: widget.request.item.series?.episodeNumber,
              tags: widget.request.item.series?.tags ?? const [],
            ),
      publisher: emptyToNull(map['publisher'] ?? ''),
      coverDate: parsedCoverDate,
      releaseDate: parsedReleaseDate,
      releaseYear: parsedReleaseDate?.year ?? widget.request.item.releaseYear,
      country: emptyToNull(map['country'] ?? ''),
      language: emptyToNull(map['language'] ?? ''),
      ageRating: emptyToNull(map['age'] ?? ''),
      genres: parsedGenres.isEmpty ? null : parsedGenres,
      storyArcs: parsedStoryArcs.isEmpty ? null : parsedStoryArcs,
      publishing: updatedPublishing.hasData ? updatedPublishing : null,
      creators: updatedCreators.isEmpty ? null : updatedCreators,
      characters: updatedCharacters.isEmpty ? null : updatedCharacters,
      characterDetails:
          updatedCharacterDetails.isEmpty ? null : updatedCharacterDetails,
      trailerUrls: updatedLinks,
    );

    final normalizedAnchorType =
        emptyToNull(map['referenceScope'] as String? ?? '') ??
            PersonalItemAnchorType.item.apiValue;
    final isVariantScope =
        normalizedAnchorType == PersonalItemAnchorType.variant.apiValue;
    final normalizedStatus = emptyToNull(map['status'] ?? '');

    Navigator.of(context).pop(
      LibraryEditSelection(
        item: updatedItem,
        personal: widget.request.ownedItem == null
            ? null
            : LibraryPersonalEditSelection(
                anchorType: normalizedAnchorType,
                editionId: isVariantScope ? widget.request.ownedItem?.editionId : null,
                variantId: isVariantScope ? widget.request.ownedItem?.variantId : null,
                bundleReleaseId: null,
                condition: null,
                grade: emptyToNull(map['grade'] ?? ''),
                purchaseDate: parseDate(map['purchaseDate'] ?? ''),
                pricePaidCents: parseMoneyCents(map['purchasePrice'] ?? ''),
                currency: emptyToNull(map['purchaseCurrency'] ?? ''),
                personalNotes: emptyToNull(map['notes'] ?? ''),
                quantity: widget.request.ownedItem?.quantity ?? 1,
                locationId: null,
                locationChanged: false,
                tags: emptyToNull(map['tags'] ?? ''),
                soldAt: parseDate(map['soldDate'] ?? ''),
                sellPriceCents: parseMoneyCents(map['soldPrice'] ?? ''),
                soldTo: null,
                rawOrSlabbed: emptyToNull(map['rawOrSlabbed'] ?? ''),
                gradingCompany: emptyToNull(map['gradingCompany'] ?? ''),
                graderNotes: emptyToNull(map['graderNotes'] ?? ''),
                signedBy: emptyToNull(map['signedBy'] ?? ''),
                labelType: emptyToNull(map['labelType'] ?? ''),
                certificationNumber:
                    emptyToNull(map['certificationNumber'] ?? ''),
                keyComic: (map['isKeyComic'] as bool?) ?? false,
                keyReason: emptyToNull(map['keyReason'] ?? ''),
                coverPriceCents: parseMoneyCents(map['coverPrice'] ?? ''),
                customLabel: emptyToNull(map['customLabel'] ?? ''),
                pageQuality: emptyToNull(map['pageQuality'] ?? ''),
                purchaseStore: emptyToNull(map['purchaseStore'] ?? ''),
                keyCategory: emptyToNull(map['keyCategory'] ?? ''),
                keySeverity: emptyToNull(map['keySeverity'] ?? ''),
                marketValueCents: parseMoneyCents(map['currentValue'] ?? ''),
                ownerLabel: emptyToNull(map['owner'] ?? ''),
                lastBagBoardDate: parseDate(map['bagBoardDate'] ?? ''),
              ),
        tracking: normalizedStatus == null && widget.request.trackingEntry == null
            ? null
            : LibraryTrackingEditSelection(
                editionId: widget.request.trackingEntry?.editionId,
                variantId: widget.request.trackingEntry?.variantId,
                rating: parseInt(map['rating'] ?? ''),
                readStatus: normalizedStatus,
                startedAt: widget.request.trackingEntry?.startedAt,
                finishedAt: parseDate(map['readDate'] ?? ''),
                progressCurrent: widget.request.trackingEntry?.progressCurrent,
                progressTotal: widget.request.trackingEntry?.progressTotal,
                timesCompleted: widget.request.trackingEntry?.timesCompleted,
                notes: widget.request.trackingEntry?.notes,
                seasonNumber: widget.request.trackingEntry?.seasonNumber,
                episodeNumber: widget.request.trackingEntry?.episodeNumber,
              ),
        customFieldEdits:
            Map<String, String?>.from(map['customFieldEdits'] as Map<String, String?>? ?? const {}),
        itemImageEdits: List<ItemImageEdit>.from(
          map['itemImageEdits'] as List<ItemImageEdit>? ?? const [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final variantSuffix = emptyToNull(widget.request.item.variant ?? '');
    final title = variantSuffix == null
        ? widget.request.item.title
        : '${widget.request.item.title} #$variantSuffix';
    return LibraryEditDialogScaffold(
      formKey: _formKey,
      accent: widget.request.accent,
      icon: widget.request.type.workspace.icon,
      title: 'Edit ${widget.request.type.singularLabel.toLowerCase()} — $title',
      badges: [
        const EditMiniBadge('Comics'),
        if (emptyToNull(widget.request.item.physicalFormatLabel ?? '') != null)
          EditMiniBadge(widget.request.item.physicalFormatLabel!),
        if (widget.request.ownedItem != null) const EditMiniBadge('Owned'),
        if (widget.request.ownedItem == null && widget.request.trackingEntry != null)
          const EditMiniBadge('Tracked'),
      ],
      body: ComicEditPanel(key: _panelKey, request: widget.request),
      onClose: () => Navigator.of(context).pop(null),
      onSave: _submit,
      tabOrderKey: null,
      allowTabReorder: false,
      ebaySearchQuery: widget.request.item.itemNumber != null
          ? '${widget.request.item.title} #${widget.request.item.itemNumber}'
          : widget.request.item.title,
    );
  }
}
