import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
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

  @override
  Widget build(BuildContext context) {
    final variantSuffix = emptyToNull(widget.request.item.variant ?? '');
    final title = variantSuffix == null
        ? widget.request.item.title
        : '${widget.request.item.title} #$variantSuffix';
    return Dialog(
      child: SizedBox(
        width: 980,
        height: 680,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(null),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ComicEditPanel(key: _panelKey, request: widget.request),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
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
                      final parsedStoryArcs =
                          ((map['storyArcs'] as String?) ?? '')
                              .split(',')
                              .map((storyArc) => storyArc.trim())
                              .where((storyArc) => storyArc.isNotEmpty)
                              .toList();
                      final parsedCrossover =
                          emptyToNull(map['crossover'] ?? '');
                      final parsedSummary = emptyToNull(map['summary'] ?? '');
                      final parsedDescription =
                          emptyToNull(map['description'] ?? '');
                      final parsedReleaseDate = parseDate(
                        map['releaseDate'] ?? '',
                      );
                      final parsedCoverDate = parseDate(
                        map['coverDate'] ?? '',
                      );
                      final seriesTitle = emptyToNull(map['series'] ?? '');
                      final updatedPublishing = CatalogPublishingDetails(
                        pageCount: parseInt(map['pages'] as String? ?? ''),
                        coverPriceCents:
                            widget.request.item.publishing?.coverPriceCents,
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
                                    emptyToNull(
                                      creator['name']?.toString() ?? '',
                                    ) !=
                                    null,
                              )
                              .map((creator) {
                        final normalized = <String, dynamic>{
                          ...creator,
                          'name': creator['name']?.toString() ?? '',
                          'role': creator['role']?.toString() ?? '',
                        };
                        normalized.removeWhere(
                          (key, value) =>
                              value == null ||
                              (value is String && value.trim().isEmpty),
                        );
                        return normalized;
                      }).toList();
                      final updatedCharacters =
                          ((map['characters'] as List<dynamic>?) ?? const [])
                              .map((character) => character.toString().trim())
                              .where((character) => character.isNotEmpty)
                              .toList();
                      final updatedCharacterDetails =
                          ((map['characterDetails'] as List<dynamic>?) ??
                                  const [])
                              .whereType<Map<String, dynamic>>()
                              .where(
                                (character) =>
                                    emptyToNull(
                                      character['name']?.toString() ?? '',
                                    ) !=
                                    null,
                              )
                              .map((character) {
                        final normalized = <String, dynamic>{
                          ...character,
                          'name': character['name']?.toString() ?? '',
                        };
                        normalized.removeWhere(
                          (key, value) =>
                              value == null ||
                              (value is String && value.trim().isEmpty),
                        );
                        return normalized;
                      }).toList();
                      final updatedLinks =
                          ((map['links'] as List<dynamic>?) ?? const [])
                              .whereType<Map<String, dynamic>>()
                              .map(
                                (link) => TrailerLink(
                                  url: link['url']?.toString().trim() ?? '',
                                  title: emptyToNull(
                                    link['title']?.toString() ?? '',
                                  ),
                                  isAutomatic: false,
                                ),
                              )
                              .where((link) => link.url.isNotEmpty)
                              .toList();

                      final updatedItem = widget.request.item.copyWith(
                        title: emptyToNull(map['title'] ?? '') ??
                            widget.request.item.title,
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
                        editionTitle: emptyToNull(
                          map['variantDescription'] ?? '',
                        ),
                        physicalFormatLabel: emptyToNull(map['format'] ?? ''),
                        barcode: emptyToNull(map['barcode'] ?? ''),
                        variant: emptyToNull(map['variant'] ?? ''),
                        series: seriesTitle == null &&
                                widget.request.item.series == null
                            ? null
                            : CatalogSeriesDetails(
                                seriesId: widget.request.item.series?.seriesId,
                                seriesTitle: seriesTitle,
                                volumeName:
                                    widget.request.item.series?.volumeName,
                                volumeNumber:
                                    widget.request.item.series?.volumeNumber,
                                volumeStartYear:
                                    widget.request.item.series?.volumeStartYear,
                                seasonNumber:
                                    widget.request.item.series?.seasonNumber,
                                episodeNumber:
                                    widget.request.item.series?.episodeNumber,
                                tags: widget.request.item.series?.tags ??
                                    const [],
                              ),
                        publisher: emptyToNull(map['publisher'] ?? ''),
                        coverDate: parsedCoverDate,
                        releaseDate: parsedReleaseDate,
                        releaseYear: parsedReleaseDate?.year ??
                            widget.request.item.releaseYear,
                        country: emptyToNull(map['country'] ?? ''),
                        language: emptyToNull(map['language'] ?? ''),
                        ageRating: emptyToNull(map['age'] ?? ''),
                        genres: parsedGenres.isEmpty ? null : parsedGenres,
                        storyArcs:
                            parsedStoryArcs.isEmpty ? null : parsedStoryArcs,
                        publishing: updatedPublishing.hasData
                            ? updatedPublishing
                            : null,
                        creators:
                            updatedCreators.isEmpty ? null : updatedCreators,
                        characters: updatedCharacters.isEmpty
                            ? null
                            : updatedCharacters,
                        characterDetails: updatedCharacterDetails.isEmpty
                            ? null
                            : updatedCharacterDetails,
                        trailerUrls: updatedLinks,
                      );

                      final personal = widget.request.ownedItem == null
                          ? null
                          : LibraryPersonalEditSelection(
                              anchorType:
                                  widget.request.ownedItem?.anchorType ??
                                      PersonalItemAnchorType.item.apiValue,
                              editionId: widget.request.ownedItem?.editionId,
                              variantId: widget.request.ownedItem?.variantId,
                              bundleReleaseId:
                                  widget.request.ownedItem?.bundleReleaseId,
                              condition: null,
                              grade: emptyToNull(map['grade'] ?? ''),
                              purchaseDate:
                                  parseDate(map['purchaseDate'] ?? ''),
                              pricePaidCents:
                                  parseMoneyCents(map['purchasePrice'] ?? ''),
                              currency:
                                  emptyToNull(map['purchaseCurrency'] ?? ''),
                              personalNotes: emptyToNull(map['notes'] ?? ''),
                              quantity: widget.request.ownedItem?.quantity ?? 1,
                              locationId: null,
                              locationChanged: false,
                              tags: emptyToNull(map['tags'] ?? ''),
                              soldAt: parseDate(map['soldDate'] ?? ''),
                              sellPriceCents:
                                  parseMoneyCents(map['soldPrice'] ?? ''),
                              rawOrSlabbed:
                                  emptyToNull(map['rawOrSlabbed'] ?? ''),
                              gradingCompany: emptyToNull(
                                map['gradingCompany'] ?? '',
                              ),
                              graderNotes:
                                  emptyToNull(map['graderNotes'] ?? ''),
                              signedBy: emptyToNull(map['signedBy'] ?? ''),
                              labelType: emptyToNull(map['labelType'] ?? ''),
                              customLabel:
                                  emptyToNull(map['customLabel'] ?? ''),
                              pageQuality:
                                  emptyToNull(map['pageQuality'] ?? ''),
                              certificationNumber: emptyToNull(
                                map['certificationNumber'] ?? '',
                              ),
                              keyComic: map['keyComic'] == true,
                              keyReason: emptyToNull(map['keyReason'] ?? ''),
                              keyCategory:
                                  emptyToNull(map['keyCategory'] ?? ''),
                              keySeverity:
                                  emptyToNull(map['keySeverity'] ?? ''),
                              coverPriceCents: parseMoneyCents(
                                map['coverPrice'] ?? '',
                              ),
                              purchaseStore: emptyToNull(
                                map['purchaseStore'] ?? '',
                              ),
                              lastBagBoardDate: parseDate(
                                map['bagBoardDate'] ?? '',
                              ),
                              marketValueCents: parseMoneyCents(
                                map['currentValue'] ?? '',
                              ),
                              ownerLabel: emptyToNull(map['owner'] ?? ''),
                            );

                      final tracking = widget.request.ownedItem == null &&
                              widget.request.trackingEntry == null
                          ? null
                          : LibraryTrackingEditSelection(
                              editionId:
                                  widget.request.trackingEntry?.editionId ??
                                      widget.request.ownedItem?.editionId,
                              variantId:
                                  widget.request.trackingEntry?.variantId ??
                                      widget.request.ownedItem?.variantId,
                              rating: parseInt(map['rating'] ?? ''),
                              readStatus: emptyToNull(map['status'] ?? ''),
                              finishedAt: parseDate(map['readDate'] ?? ''),
                              notes: widget.request.trackingEntry?.notes,
                            );

                      final customFieldEdits = Map<String, String?>.from(
                        (map['customFieldEdits'] as Map<String, String?>?) ??
                            const <String, String?>{},
                      );
                      final itemImageEdits =
                          ((map['itemImageEdits'] as List<dynamic>?) ??
                                  const [])
                              .whereType<ItemImageEdit>()
                              .toList();

                      final selection = LibraryEditSelection(
                        item: updatedItem,
                        personal: personal,
                        tracking: tracking,
                        customFieldEdits: customFieldEdits,
                        itemImageEdits: itemImageEdits,
                      );

                      Navigator.of(context).pop(selection);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
