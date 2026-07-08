import 'package:collectarr_app/features/library/edit/anchor_selection_helpers.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_edit_image_sections.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_creator_roles.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_host.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_models.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

extension ComicEditTabBuilders on ComicEditHost {
  Widget buildComicOwnedDetailsTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Details',
          accent: comicAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: comicTitleController,
                  label: 'Title',
                ),
                LibraryEditTextField(
                  controller: comicOriginalTitleController,
                  label: 'Original title',
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: comicEditionTitleController,
                  label: 'Edition title',
                ),
                LibraryEditTextField(
                  controller: comicVariantController,
                  label: 'Variant / format',
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                buildComicCrossoverPickField(),
                buildComicStoryArcPickField(),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                buildComicCountryPickField(),
                LibraryEditTextField(controller: comicLanguageController, label: 'Language'),
              ]),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 620) {
                    return Column(
                      children: [
                        LibraryEditTextField(
                          controller: comicAgeRatingController,
                          label: 'Age',
                        ),
                        const SizedBox(height: 10),
                        LibraryEditTextField(
                          controller: comicPageCountController,
                          label: 'No. of Pages',
                          validator: optionalIntValidator,
                        ),
                        const SizedBox(height: 10),
                        TagPickListField(
                          controller: comicGenresEditController,
                          options: comicGenreOptions,
                          label: 'Genres',
                        ),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: LibraryEditTextField(
                                controller: comicAgeRatingController,
                                label: 'Age',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: LibraryEditTextField(
                                controller: comicPageCountController,
                                label: 'No. of Pages',
                                validator: optionalIntValidator,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child:                         TagPickListField(
                          controller: comicGenresEditController,
                          options: comicGenreOptions,
                          label: 'Genres',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        EditSection(
          title: 'Advanced',
          accent: comicAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(controller: comicSortKeyController, label: 'Sort title'),
                TextFormField(
                  controller: comicSearchAliasesController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Search aliases',
                    hintText: 'Comma-separated aliases',
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: comicLocalizedTitleController,
                  label: 'Localized title',
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildComicCreatorsTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Creators',
          accent: comicAccent,
          child: Column(
            children: [
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => comicMutateState(
                      () => comicCreators.add(EditableComicCreator.custom()),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _addCatalogComicCreator,
                    icon: const Icon(Icons.person_search_outlined, size: 16),
                    label: const Text('Find in Catalog'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (comicCreators.isEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Creators is empty',
                    style: TextStyle(color: appPalette(comicContext).textMuted),
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorderItem: (oldIndex, newIndex) {
                    comicMutateState(() {
                      final item = comicCreators.removeAt(oldIndex);
                      comicCreators.insert(newIndex, item);
                    });
                  },
                  itemCount: comicCreators.length,
                  itemBuilder: (context, index) {
                    final creator = comicCreators[index];
                    final currentRole = creator.roleController.text.trim();
                    final roles = <String>[
                      if (currentRole.isNotEmpty &&
                          !kComicCreatorRoles.contains(currentRole))
                        currentRole,
                      ...kComicCreatorRoles,
                    ];
                    return Padding(
                      key: ValueKey(creator),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          ReorderableDragStartListener(
                            index: index,
                            child: Icon(
                              Icons.drag_handle,
                              color: appPalette(comicContext).textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 180,
                            child: DropdownButtonFormField<String>(
                              initialValue:
                                  currentRole.isEmpty ? null : currentRole,
                              items: [
                                for (final role in roles)
                                  DropdownMenuItem(
                                      value: role, child: Text(role)),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                creator.roleController.text = value;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Role',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: creator.nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _lookupComicCreatorForRow(index),
                            icon: const Icon(Icons.person_search, size: 18),
                            tooltip: 'Lookup',
                          ),
                          IconButton(
                            onPressed: () => comicMutateState(
                              () => comicCreators.removeAt(index).dispose(),
                            ),
                            icon: const Icon(Icons.close, size: 18),
                            tooltip: 'Remove',
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

  Widget buildComicCharactersTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Characters',
          accent: comicAccent,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: comicCharacterDraftController,
                      decoration:
                          const InputDecoration(hintText: 'Character name'),
                      onSubmitted: (_) => _addComicCharacter(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _addComicCharacter,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _addCatalogComicCharacter,
                    icon: const Icon(Icons.person_search_outlined, size: 16),
                    label: const Text('Find in Catalog'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (comicCharacters.isEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Characters is empty',
                    style: TextStyle(color: appPalette(comicContext).textMuted),
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorderItem: (oldIndex, newIndex) {
                    comicMutateState(() {
                      final item = comicCharacters.removeAt(oldIndex);
                      comicCharacters.insert(newIndex, item);
                    });
                  },
                  itemCount: comicCharacters.length,
                  itemBuilder: (context, index) {
                    final character = comicCharacters[index];
                    return Padding(
                      key: ValueKey(character),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          ReorderableDragStartListener(
                            index: index,
                            child: Icon(
                              Icons.drag_handle,
                              color: appPalette(comicContext).textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              controller: character.nameController,
                              decoration: const InputDecoration(
                                labelText: 'Character',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: character.realNameController,
                              decoration: const InputDecoration(
                                labelText: 'Real name',
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => comicMutateState(
                              () => comicCharacters.removeAt(index).dispose(),
                            ),
                            icon: const Icon(Icons.close, size: 18),
                            tooltip: 'Remove',
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

  Widget buildComicLinksTab() {
    final palette = appPalette(comicContext);
    return EditTabShell(
      children: [
        EditSection(
          title: 'External Links',
          accent: comicAccent,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: palette.surfaceSubtle.withValues(alpha: 0.5),
                  border: Border.all(color: palette.divider),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: palette.divider),
                        ),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 48),
                          Expanded(
                            flex: 5,
                            child: Text(
                              'URL',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Description',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (comicLinks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'No links added yet',
                            style: TextStyle(color: palette.textMuted),
                          ),
                        ),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        onReorderItem: (oldIndex, newIndex) {
                          comicMutateState(() {
                            final item = comicLinks.removeAt(oldIndex);
                            comicLinks.insert(newIndex, item);
                          });
                        },
                        itemCount: comicLinks.length,
                        itemBuilder: (context, index) {
                          final link = comicLinks[index];
                          return Container(
                            key: ValueKey(link),
                            padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: palette.divider),
                              ),
                            ),
                            child: Row(
                              children: [
                                ReorderableDragStartListener(
                                  index: index,
                                  child: Icon(
                                    Icons.drag_handle,
                                    color: palette.textMuted,
                                  ),
                                ),
                                SizedBox(
                                  width: 28,
                                  child: Checkbox(
                                    value: false,
                                    onChanged: (value) {
                                      if (value != true) return;
                                      comicMutateState(() {
                                        final removed =
                                            comicLinks.removeAt(index);
                                        removed['title']?.dispose();
                                        removed['url']?.dispose();
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: TextFormField(
                                    controller: link['url'],
                                    decoration: const InputDecoration(
                                      hintText: 'https://',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    controller: link['title'],
                                    decoration: const InputDecoration(),
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
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => comicMutateState(
                    () => comicLinks.add(comicCreateLinkControllers()),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Link'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildComicMainTab() {
    final editPresentation = comicEditPresentation;
    return EditTabShell(
      children: [
        _ownedComicMainOverviewCard(),
        if (editPresentation.showsOwnershipReferenceSection)
          EditSection(
            title: editPresentation.ownershipReferenceTitle,
            accent: comicAccent,
            child: Column(
              children: [
                buildComicOwnershipAnchorSelectionField(),
                if (comicSelectedOwnedAnchorType ==
                        PersonalItemAnchorType.edition.apiValue ||
                    comicSelectedOwnedAnchorType ==
                        PersonalItemAnchorType.variant.apiValue) ...[
                  const SizedBox(height: 10),
                  LibraryEditResponsiveRow(children: [
                    buildComicEditionSelectionField(),
                    if (comicSelectedOwnedAnchorType ==
                        PersonalItemAnchorType.variant.apiValue)
                      buildComicVariantSelectionField(),
                  ]),
                ],
                if (comicSelectedOwnedAnchorType ==
                    PersonalItemAnchorType.bundleRelease.apiValue) ...[
                  const SizedBox(height: 10),
                  buildComicBundleReleaseSelectionField(
                    fieldKey: const Key('library-edit-owned-bundle-field'),
                    label: editPresentation.ownedBundleLabel,
                    selectedBundleReleaseId: comicSelectedBundleReleaseId,
                    onChanged: (value) {
                      comicMutateState(() {
                        comicSelectedBundleReleaseId =
                            normalizeLibrarySelectionId(value);
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        EditSection(
          title: 'Storage & Notes',
          accent: comicAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (comicShowPhysicalOwnedFields) ...[
                LibraryEditResponsiveRow(children: [
                  LibraryEditTextField(
                    controller: comicOwnerLabelController,
                    label: 'Owner',
                    hint: 'Name of the owner',
                  ),
                ]),
                const SizedBox(height: 10),
              ] else ...[
                Text(
                  'Digital copies do not expose physical storage fields.',
                  style: TextStyle(color: appPalette(comicContext).textMuted),
                ),
                const SizedBox(height: 10),
              ],
              TagPickListField(
                controller: comicTagsController,
                options: comicTagOptions,
                label: 'Tags',
                hint: 'Comma-separated tags',
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
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: comicStorageDeviceController,
                  label: 'Storage device',
                ),
                LibraryEditTextField(
                  controller: comicStorageSlotController,
                  label: 'Storage slot',
                ),
              ]),
              const SizedBox(height: 10),
              TextFormField(
                controller: comicTrackingNotesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Tracking notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: comicNotesController,
                minLines: 4,
                maxLines: 7,
                decoration: const InputDecoration(
                  labelText: 'Personal notes',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildComicValueTab() {
    final editPresentation = comicEditPresentation;
    return EditTabShell(
      children: [
        EditSection(
          title: 'Value',
          accent: comicAccent,
          child: Column(
            children: [
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(controller: comicGradeController, label: 'Grade'),
                LibraryEditTextField(
                  controller: comicConditionController,
                  label: 'Condition',
                ),
                _comicRawOrSlabbedField(),
                LibraryEditTextField(
                  controller: comicGradingCompanyController,
                  label: 'Grading company',
                ),
                LibraryEditTextField(
                  controller: comicCertificationNumberController,
                  label: 'Certification number',
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(controller: comicLabelTypeController, label: 'Label type'),
                LibraryEditTextField(controller: comicSignedByController, label: 'Signed by'),
                buildComicPageQualityPickField(label: 'Page quality'),
                LibraryEditTextField(
                  controller: comicCoverPriceController,
                  label: 'Cover price',
                  validator: optionalMoneyValidator,
                ),
              ]),
              const SizedBox(height: 10),
              TextFormField(
                controller: comicGraderNotesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Grader notes',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 10),
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  value: comicKeyComic,
                  onChanged: (value) =>
                      comicMutateState(() => comicKeyComic = value),
                  title: Text(editPresentation.keyToggleLabel),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              if (comicKeyComic) ...[
                const SizedBox(height: 6),
                LibraryEditResponsiveRow(children: [
                  LibraryEditTextField(
                    controller: comicKeyReasonController,
                    label: editPresentation.keyReasonLabel,
                  ),
                  buildComicKeyCategoryPickField(label: 'Key category'),
                ]),
              ],
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: comicPriceController,
                  label: 'Price paid',
                  validator: optionalMoneyValidator,
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryCurrencyField(controller: comicCurrencyController),
                LibraryEditTextField(
                  controller: comicMarketValueController,
                  label: 'My value',
                  validator: optionalMoneyValidator,
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: comicPurchaseStoreController,
                  label: 'Purchase store',
                ),
                LibraryDateFieldButton(
                  label: 'Purchase date',
                  value: parseDate(comicPurchaseDateController.text),
                  onChanged: (value) {
                    comicMutateState(() {
                      comicPurchaseDateController.text =
                          value == null ? '' : formatDate(value);
                    });
                  },
                ),
              ]),
              const SizedBox(height: 10),
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  value: comicSoldAt != null,
                  onChanged: (value) {
                    comicMutateState(() {
                      comicSoldAt = value ? DateTime.now() : null;
                    });
                  },
                  title: const Text('Mark as sold'),
                  subtitle: comicSoldAt != null
                      ? Text(
                          'Sold on ${formatDate(comicSoldAt!)}',
                          style:
                              TextStyle(color: appPalette(comicContext).textMuted),
                        )
                      : null,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (comicSoldAt != null) ...[
                const SizedBox(height: 12),
                LibraryEditResponsiveRow(children: [
                  LibraryEditTextField(
                    controller: comicSellPriceController,
                    label: 'Price sold',
                    validator: optionalMoneyValidator,
                  ),
                  LibraryDateFieldButton(
                    label: 'Sold date',
                    value: comicSoldAt,
                    onChanged: (value) =>
                        comicMutateState(() => comicSoldAt = value),
                  ),
                  LibraryEditTextField(
                    controller: comicSoldToController,
                    label: 'Sold to',
                  ),
                ]),
                const SizedBox(height: 12),
                SoldSummaryPanel(
                  pricePaidCents: parseMoneyCents(comicPriceController.text),
                  sellPriceCents: parseMoneyCents(comicSellPriceController.text),
                  currency: comicCurrencyController.text,
                ),
              ],
              const SizedBox(height: 10),
              LibraryDateFieldButton(
                label: 'Last bag & board date',
                value: comicLastBagBoardDate,
                onChanged: (value) =>
                    comicMutateState(() => comicLastBagBoardDate = value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _comicRawOrSlabbedField() {
    final rawValue = comicRawOrSlabbedController.text.trim().toLowerCase();
    final selected = rawValue == 'slabbed' ? 'slabbed' : 'raw';
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Raw / Slabbed'),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment<String>(value: 'raw', label: Text('Raw')),
          ButtonSegment<String>(value: 'slabbed', label: Text('Slabbed')),
        ],
        selected: {selected},
        showSelectedIcon: false,
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        onSelectionChanged: (selection) {
          comicMutateState(() {
            final value = selection.first;
            comicRawOrSlabbedController.text =
                value == 'slabbed' ? 'Slabbed' : 'Raw';
          });
        },
      ),
    );
  }

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
                        TextFormField(
                          controller: comicNotesController,
                          minLines: 6,
                          maxLines: 9,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            alignLabelWithHint: true,
                          ),
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
                          child: TextFormField(
                            controller: comicNotesController,
                            expands: true,
                            minLines: null,
                            maxLines: null,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              alignLabelWithHint: true,
                            ),
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

  Widget _ownedComicMainOverviewCard() {
    final mediaFields = comicLibraryType.mediaFields;
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
                      LibraryEditTextField(controller: comicBarcodeController, label: 'Barcode'),
                      _comicFormatField(),
                    ],
                    flexes: const [1, 1],
                    breakpoint: 520,
                  ),
                  if (mediaFields.showSeriesGroup) ...[
                    const SizedBox(height: 10),
                    buildComicSeriesGroupField(label: 'Series Group'),
                  ],
                ],
              );
              final rightColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildComicFlexRow(
                    [
                      LibraryEditTextField(controller: comicNumberController, label: 'Issue No.'),
                      LibraryEditTextField(controller: comicVariantController, label: 'Variant'),
                      LibraryEditTextField(
                        controller: comicEditionTitleController,
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
                      if (mediaFields.showImprint) buildComicImprintField(),
                    ],
                    flexes: [1, if (mediaFields.showImprint) 1],
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
    return _datePartsGroup(
      label: 'Cover Date',
      children: [
        _datePartField(
          key: const Key('comic-cover-date-year'),
          controller: comicCoverDateYearPartController,
          placeholder: 'YYYY',
          validator: optionalIntValidator,
          onChanged: (_) => _syncCoverDateFromParts(),
        ),
        _datePartField(
          key: const Key('comic-cover-date-month'),
          controller: comicCoverDateMonthPartController,
          placeholder: 'MM',
          validator: optionalIntValidator,
          onChanged: (_) => _syncCoverDateFromParts(),
        ),
        _datePartField(
          key: const Key('comic-cover-date-day'),
          controller: comicCoverDateDayPartController,
          placeholder: 'DD',
          validator: optionalIntValidator,
          onChanged: (_) => _syncCoverDateFromParts(),
        ),
      ],
    );
  }

  Widget _releaseDatePartsField() {
    return _datePartsGroup(
      label: 'Release Date',
      children: [
        _datePartField(
          key: const Key('comic-release-date-year'),
          controller: comicReleaseDateYearPartController,
          placeholder: 'YYYY',
          validator: optionalIntValidator,
          onChanged: (_) => _syncReleaseDateFromParts(),
        ),
        _datePartField(
          key: const Key('comic-release-date-month'),
          controller: comicReleaseDateMonthPartController,
          placeholder: 'MM',
          validator: optionalIntValidator,
          onChanged: (_) => _syncReleaseDateFromParts(),
        ),
        _datePartField(
          key: const Key('comic-release-date-day'),
          controller: comicReleaseDateDayPartController,
          placeholder: 'DD',
          validator: optionalIntValidator,
          onChanged: (_) => _syncReleaseDateFromParts(),
        ),
      ],
    );
  }

  Widget _datePartsGroup({
    required String label,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: appPalette(comicContext).textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index != children.length - 1) const SizedBox(width: 6),
            ],
          ],
        ),
      ],
    );
  }

  Widget _datePartField({
    Key? key,
    TextEditingController? controller,
    required String placeholder,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
      maxLength: placeholder.length,
      validator: validator,
      decoration: InputDecoration(
        counterText: '',
        hintText: placeholder,
      ),
    );
  }

  void _syncCoverDateFromParts() {
    final year = comicCoverDateYearPartController.text.trim();
    final month = comicCoverDateMonthPartController.text.trim();
    final day = comicCoverDateDayPartController.text.trim();
    if (year.isEmpty && month.isEmpty && day.isEmpty) {
      comicCoverDateController.text = '';
      return;
    }
    if (year.length != 4 || month.length != 2 || day.length != 2) {
      comicCoverDateController.text = '';
      return;
    }
    final parsed = DateTime.tryParse('$year-$month-$day');
    comicCoverDateController.text = parsed == null ? '' : formatDate(parsed);
  }

  void _syncReleaseDateFromParts() {
    final year = comicReleaseDateYearPartController.text.trim();
    final month = comicReleaseDateMonthPartController.text.trim();
    final day = comicReleaseDateDayPartController.text.trim();
    if (year.isEmpty && month.isEmpty && day.isEmpty) {
      comicReleaseDateController.text = '';
      return;
    }
    if (year.length != 4 || month.length != 2 || day.length != 2) {
      comicReleaseDateController.text = '';
      return;
    }
    final parsed = DateTime.tryParse('$year-$month-$day');
    comicReleaseDateController.text = parsed == null ? '' : formatDate(parsed);
  }

  Future<void> _addCatalogComicCreator() async {
    final api = comicRef.read(apiClientProvider);
    final creator = await _showComicLookupDialog(
      title: 'Find creator',
      searchHint: 'Search creators',
      search: (query) => api.searchCreators(query: query, limit: 24),
      titleForResult: (result) => result['name']?.toString() ?? 'Creator',
      subtitleForResult: (result) {
        final itemCount = (result['item_count'] as num?)?.toInt();
        final description = result['description']?.toString().trim();
        return [
          if (itemCount != null) '$itemCount credits',
          if (description != null && description.isNotEmpty) description,
        ].join(' · ');
      },
    );
    if (creator == null) return;
    comicMutateState(
      () => comicCreators.add(EditableComicCreator.fromLookupResult(creator)),
    );
  }

  Future<void> _lookupComicCreatorForRow(int index) async {
    if (index < 0 || index >= comicCreators.length) return;
    final api = comicRef.read(apiClientProvider);
    final creator = await _showComicLookupDialog(
      title: 'Find creator',
      searchHint: 'Search creators',
      search: (query) => api.searchCreators(query: query, limit: 24),
      titleForResult: (result) => result['name']?.toString() ?? 'Creator',
      subtitleForResult: (result) {
        final itemCount = (result['item_count'] as num?)?.toInt();
        final description = result['description']?.toString().trim();
        return [
          if (itemCount != null) '$itemCount credits',
          if (description != null && description.isNotEmpty) description,
        ].join(' · ');
      },
    );
    if (creator == null) return;
    final role = creator['role']?.toString().trim().isNotEmpty == true
        ? creator['role']!.toString().trim()
        : creator['job']?.toString().trim().isNotEmpty == true
            ? creator['job']!.toString().trim()
            : '';
    comicMutateState(() {
      final current = comicCreators[index];
      current.nameController.text = creator['name']?.toString() ?? '';
      if (role.isNotEmpty) {
        current.roleController.text = role;
      }
      current.metadata
        ..addAll(creator)
        ..['source_type'] = 'core';
    });
  }

  void _addComicCharacter() {
    final normalized = comicCharacterDraftController.text.trim();
    if (normalized.isEmpty) return;
    final exists = comicCharacters.any((character) =>
        character.nameController.text.trim().toLowerCase() ==
        normalized.toLowerCase());
    if (exists) {
      comicCharacterDraftController.clear();
      return;
    }
    comicMutateState(() {
      comicCharacters.add(EditableComicCharacter.custom(normalized));
      comicCharacterDraftController.clear();
    });
  }

  Future<void> _addCatalogComicCharacter() async {
    final api = comicRef.read(apiClientProvider);
    final character = await _showComicLookupDialog(
      title: 'Find character',
      searchHint: 'Search characters',
      search: (query) => api.searchCharacters(query: query, limit: 24),
      titleForResult: (result) => result['name']?.toString() ?? 'Character',
      subtitleForResult: (result) {
        final count = (result['appearance_count'] as num?)?.toInt();
        return count == null ? '' : '$count appearances';
      },
    );
    if (character == null) return;
    final normalized = character['name']?.toString().trim() ?? '';
    if (normalized.isEmpty) return;
    final exists = comicCharacters.any((entry) =>
        entry.nameController.text.trim().toLowerCase() ==
        normalized.toLowerCase());
    if (exists) return;
    comicMutateState(
      () => comicCharacters
          .add(EditableComicCharacter.fromLookupResult(character)),
    );
  }

  Future<Map<String, dynamic>?> _showComicLookupDialog({
    required String title,
    required String searchHint,
    required Future<List<Map<String, dynamic>>> Function(String query) search,
    required String Function(Map<String, dynamic> result) titleForResult,
    required String Function(Map<String, dynamic> result) subtitleForResult,
  }) async {
    final searchController = TextEditingController();
    var results = const <Map<String, dynamic>>[];
    var isLoading = false;
    String? error;

    Future<void> runSearch(StateSetter setDialogState) async {
      setDialogState(() {
        isLoading = true;
        error = null;
      });
      try {
        final rows = await search(searchController.text.trim());
        setDialogState(() {
          results = rows;
          isLoading = false;
        });
      } catch (_) {
        setDialogState(() {
          error = 'Search failed. Try again.';
          isLoading = false;
        });
      }
    }

    final selected = await showDialog<Map<String, dynamic>>(
      context: comicContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 620,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(hintText: searchHint),
                            onSubmitted: (_) => runSearch(setDialogState),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => runSearch(setDialogState),
                          child: const Text('Search'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      )
                    else if (error != null)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final result = results[index];
                            final subtitle = subtitleForResult(result);
                            return ListTile(
                              title: Text(titleForResult(result)),
                              subtitle:
                                  subtitle.isEmpty ? null : Text(subtitle),
                              onTap: () =>
                                  Navigator.of(dialogContext).pop(result),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
    searchController.dispose();
    return selected;
  }

  List<ResolvedComicEditImage> _resolvedEditImages() {
    return resolveComicEditImages(
      images: comicItemImages,
      edits: comicItemImageEdits,
    );
  }

  String _buildComicMarketSearchQuery() {
    return [
      comicLibraryItem.title,
      if (emptyToNull(comicNumberController.text) case final issue?) '#$issue',
      if (emptyToNull(comicPhysicalFormatLabelController.text) case final format?)
        format,
      if (emptyToNull(comicVariantController.text) case final variant?) variant,
    ].join(' ').trim();
  }

  Widget buildComicCoverTab() {
    final coverUrl = emptyToNull(comicCoverController.text) ??
        emptyToNull(comicThumbnailController.text) ??
        comicLibraryItem.displayCoverUrl;
    final resolvedImages = _resolvedEditImages();
    final backCover = firstResolvedComicEditImageOfType(
      resolvedImages,
      'back_cover',
    );
    final frontAlt = firstResolvedComicEditImageOfType(
      resolvedImages,
      'front_cover',
    );
    final auxiliaryCount =
        resolvedImages.where((image) => image.imageType == 'auxiliary').length;
    return EditTabShell(
      children: [
        EditSection(
          title: 'Covers',
          accent: comicAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryEditTextField(controller: comicCoverController, label: 'Front Cover URL'),
              const SizedBox(height: 12),
              ComicCoverPreviewRow(
                coverUrl: coverUrl,
                frontCoverOverride: frontAlt,
                backCover: backCover,
              ),
            ],
          ),
        ),
        EditSection(
          title: 'Cover workflow',
          accent: comicAccent,
          child: ComicCoverWorkflowContent(
            imageCount: resolvedImages.length,
            auxiliaryCount: auxiliaryCount,
            bodyStyle: TextStyle(color: appPalette(comicContext).textMuted),
            onManageImages: () => comicOpenEditTab('photos'),
            onFindBetterCover: () =>
                launchEbaySearch(_buildComicMarketSearchQuery()),
          ),
        ),
      ],
    );
  }

  Widget buildComicPhotosTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'My images workflow',
          accent: comicAccent,
          child: ComicPhotosWorkflowText(
            style: TextStyle(color: appPalette(comicContext).textMuted),
          ),
        ),
        ItemImagesEditSection(
          images: comicItemImages,
          accent: comicAccent,
          onChanged: (edits) => comicItemImageEdits = edits,
        ),
      ],
    );
  }
}
