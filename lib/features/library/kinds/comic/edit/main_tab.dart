import 'package:collectarr_app/features/library/edit/fields/edit_layout_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_value_fields.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_summary_widgets.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/host.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

extension ComicMainTab on ComicEditHost {
  Widget buildComicMainTab() {
    return EditTabShell(
      children: [
        _entryComicMainOverviewCard(),
        EditSection(
          title: 'Storage & Notes',
          accent: comicAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (comicShowPhysicalEntryFields) ...[
                LibraryEditResponsiveRow(children: [
                  buildComicCollectionStatusPickField(),
                  buildComicLocationPickerField(),
                ]),
                const SizedBox(height: 10),
                LibraryEditResponsiveRow(children: [
                  LibraryEditTextField(
                    controller: comicIndexNumberController,
                    label: 'Index',
                    validator: optionalIntValidator,
                  ),
                  LibraryEditTextField(
                    controller: comicOwnerLabelController,
                    label: 'Owner',
                    hint: 'Name of the owner',
                  ),
                ]),
                const SizedBox(height: 10),
              ] else ...[
                Text(
                  'Digital items do not expose physical storage fields.',
                  style: TextStyle(color: appPalette(comicContext).textMuted),
                ),
                const SizedBox(height: 10),
              ],
              LibraryMultiVocabularyField(
                controller: comicTags,
                options: comicTagOptions,
                label: 'Tags',
              ),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryDateFieldButton(
                  label: 'Started',
                  value: comicStartedAt,
                  onChanged: (v) => comicMutateState(() => comicStartedAt = v),
                ),
                LibraryDateFieldButton(
                  label: 'Finished',
                  value: comicFinishedAt,
                  onChanged: (v) => comicMutateState(() => comicFinishedAt = v),
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditTextField(
                controller: comicTrackingNotesController,
                label: 'Tracking notes',
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 10),
              LibraryEditTextField(
                controller: comicNotesController,
                label: 'Personal notes',
                minLines: 4,
                maxLines: 7,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _entryComicMainOverviewCard() {
    final palette = appPalette(comicContext);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: palette.gridCanvas,
        shape: Border(
          left: BorderSide(color: comicAccent, width: 2),
          top: BorderSide(color: palette.surfaceBright),
          right: BorderSide(color: palette.surfaceBright),
          bottom: BorderSide(color: palette.surfaceBright),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 920;
              final leftColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildComicSeriesField(),
                  const SizedBox(height: 10),
                  buildComicFlexRow(
                    [
                      LibraryEditTextField(
                          controller: comicBarcodeController, label: 'Barcode'),
                      _comicFormatField(),
                    ],
                    flexes: const [1, 1],
                    breakpoint: 520,
                  ),
                  const SizedBox(height: 10),
                  buildComicSeriesGroupField(label: 'Series Group'),
                ],
              );
              final rightColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildComicFlexRow(
                    [
                      LibraryEditTextField(
                          controller: comicNumberController,
                          label: 'Issue No.'),
                      LibraryEditTextField(
                          controller: comicVariantController, label: 'Variant'),
                      LibraryEditTextField(
                        controller: comicVariantDescriptionController,
                        label: 'Variant Description',
                      ),
                    ],
                    flexes: const [3, 2, 7],
                    breakpoint: 720,
                  ),
                  const SizedBox(height: 10),
                  buildComicFlexRow(
                    [
                      _coverDatePartsField(),
                      _releaseDatePartsField(),
                    ],
                    flexes: const [1, 1],
                    breakpoint: 720,
                  ),
                  const SizedBox(height: 10),
                  buildComicFlexRow(
                    [
                      buildComicPublisherField(),
                      buildComicImprintField(),
                    ],
                    flexes: const [1, 1],
                    breakpoint: 720,
                  ),
                ],
              );
              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leftColumn,
                    const SizedBox(height: 10),
                    rightColumn,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: leftColumn),
                  const SizedBox(width: 10),
                  Expanded(flex: 7, child: rightColumn),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _comicFormatField() {
    return buildComicPhysicalFormatField(label: 'Format');
  }

  Widget _coverDatePartsField() {
    return _comicDateInput(
      label: 'Cover Date',
      dateController: comicCoverDateController,
      fieldKeyPrefix: 'comic-cover-date',
    );
  }

  Widget _releaseDatePartsField() {
    return _comicDateInput(
      label: 'Release Date',
      dateController: comicReleaseDateController,
      fieldKeyPrefix: 'comic-release-date',
    );
  }

  Widget _comicDateInput({
    required String label,
    required TextEditingController dateController,
    required String fieldKeyPrefix,
  }) {
    return LibraryDateFieldButton(
      label: label,
      value: parseDate(dateController.text),
      fieldKeyPrefix: fieldKeyPrefix,
      onChanged: (value) => comicMutateState(
        () => dateController.text = value == null ? '' : formatDate(value),
      ),
    );
  }
}
