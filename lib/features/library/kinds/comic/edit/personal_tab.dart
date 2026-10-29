import 'package:collectarr_app/features/library/edit/fields/edit_layout_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_value_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/host.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:flutter/material.dart';

extension ComicPersonalTab on ComicEditHost {
  Widget buildComicPersonalTab() {
    final isRead = comicTrackingController.text.trim().toLowerCase() == 'read';
    return EditTabShell(
      children: [
        EditSection(
          title: 'Personal',
          accent: comicAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildComicFlexRow(
                [
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Read'),
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(value: false, label: Text('No')),
                        ButtonSegment<bool>(value: true, label: Text('Yes')),
                      ],
                      selected: {isRead},
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      onSelectionChanged: (selection) {
                        final selected = selection.first;
                        comicMutateState(() {
                          comicTrackingController.text = selected ? 'Read' : '';
                          if (!selected) {
                            comicFinishedAt = null;
                          }
                        });
                      },
                    ),
                  ),
                  LibraryDateFieldButton(
                    label: 'Read Date',
                    value: comicFinishedAt,
                    onChanged: (value) => comicMutateState(() {
                      comicFinishedAt = value;
                      if (value != null) {
                        comicTrackingController.text = 'Read';
                      }
                    }),
                  ),
                  buildComicOwnerPickField(label: 'Owner'),
                ],
                flexes: const [4, 4, 8],
                breakpoint: 980,
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 980) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LibraryEditTextField(
                          controller: comicNotesController,
                          label: 'Notes',
                          minLines: 6,
                          maxLines: 9,
                        ),
                        const SizedBox(height: 10),
                        MediaRatingField(controller: comicRatingController),
                        const SizedBox(height: 10),
                        buildComicTagsDropdownField(label: 'Tags'),
                        const SizedBox(height: 10),
                        LibraryDateFieldButton(
                          label: 'Bag/Board Date',
                          value: comicLastBagBoardDate,
                          onChanged: (value) => comicMutateState(
                            () => comicLastBagBoardDate = value,
                          ),
                        ),
                      ],
                    );
                  }
                  return SizedBox(
                    height: 248,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 8,
                          child: LibraryEditTextField(
                            controller: comicNotesController,
                            label: 'Notes',
                            expands: true,
                            minLines: null,
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 88,
                                child: MediaRatingField(
                                  controller: comicRatingController,
                                ),
                              ),
                              const SizedBox(height: 10),
                              buildComicTagsDropdownField(label: 'Tags'),
                              const Spacer(),
                              LibraryDateFieldButton(
                                label: 'Bag/Board Date',
                                value: comicLastBagBoardDate,
                                onChanged: (value) => comicMutateState(
                                  () => comicLastBagBoardDate = value,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
