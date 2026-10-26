import '../entries/game_toy_entry_details.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_personal_tab.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_status_strip.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_draft_editor.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/add/draft.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/add/manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/add/schema.dart';

import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/edit/covers_tab.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/edit/personal_form_layout.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/edit/value_tab.dart';

import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';

class GameToyAddManualPane extends StatefulWidget {
  const GameToyAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  State<GameToyAddManualPane> createState() => _GameToyAddManualPaneState();
}

class _GameToyAddManualPaneState extends State<GameToyAddManualPane> {
  late final TextEditingController _rating;

  LibraryAddManualPaneRequest get request => widget.request;
  GameToyAddDraft get _personal => request.kindDraft is GameToyAddDraft
      ? request.kindDraft as GameToyAddDraft
      : const GameToyAddDraft();

  void _update(GameToyAddDraft value) =>
      request.onKindDraftChanged?.call(value);

  @override
  void initState() {
    super.initState();
    _rating = TextEditingController(text: _personal.rating?.toString() ?? '')
      ..addListener(() =>
          _update(_personal.copyWith(rating: int.tryParse(_rating.text))));
  }

  @override
  void dispose() {
    _rating.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<GameToyAddManualDraft>();
    final personal = _personal;
    return LibraryAddManualPaneShell(
      request: request,
      footerContent: LibraryAddStatusStrip(
        request: request,
        indexValue: personal.indexNumber,
        quantity: personal.quantity,
        onIndexChanged: (value) =>
            _update(personal.copyWith(indexNumber: value)),
        onQuantityChanged: (value) =>
            _update(personal.copyWith(quantity: value)),
      ),
      tabs: [
        LibraryAddManualPaneTab.fromSchema<GameToyAddManualDraft>(
          id: 'main',
          label: 'Main',
          icon: AppIcons.gamepad,
          schema: gameToyAddSchema,
          draft: draft,
          mediaKind: request.kind.apiValue,
          onVocabularyValueChanged: request.onVocabularyValueChanged,
          onVocabularyValuesChanged: request.onVocabularyValuesChanged,
          onChanged: request.onManualDraftChanged,
          validateSchema: true,
        ),
        LibraryAddManualPaneTab(
          id: 'value',
          label: 'Value',
          icon: AppIcons.tabValue,
          content: LibraryAddManualPersonalTab(
            request: request,
            layoutBuilder: gameToyValueLayout,
            fieldOverrides: {
              ...gameToyValueFields(_AddValueBindings(request, personal)),
              'purchase_date': _purchaseDate(personal),
            },
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'personal',
          label: 'Personal',
          icon: AppIcons.tabPersonal,
          content: LibraryAddManualPersonalTab(
            request: request,
            layoutBuilder: gameToyPersonalFormLayout,
            fieldOverrides: {
              'rating': LibraryFormField(
                label: 'My Rating',
                child: MediaRatingField(
                    controller: _rating, showLabel: false, compact: true),
              ),
            },
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'custom_fields',
          label: 'Custom Fields',
          icon: AppIcons.tabCustomFields,
          content: CustomFieldsEditSection(
            definitions: request.customFieldDefinitions,
            values: request.customFieldValues,
            accent: request.accent,
            mediaKind: 'game_toy',
            onChanged: (values) =>
                request.onCustomFieldValuesChanged?.call(values),
            onCustomValueChanged: (id, value) =>
                request.onVocabularyValueChanged?.call(
                    fieldId: 'customField:$id',
                    listName: 'customField:$id',
                    value: value),
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'covers',
          label: 'Image',
          icon: AppIcons.tabCovers,
          content: GameToyCoversTab(
            images: [
              for (final image in request.itemImages)
                if (_isCover(image)) image,
            ],
            coverImageUrl: draft.values.coverImageUrl,
            originalCoverImageUrl: '',
            onCoverImageUrlChanged: (value) {
              draft.values.coverImageUrl = value;
              request.onManualDraftChanged?.call();
            },
            onEdits: (edits) {
              final changed = {for (final edit in edits) edit.imageType};
              request.onItemImagesChanged?.call([
                for (final image in request.itemImages)
                  if (!changed.contains(image.imageType)) _imageEdit(image),
                for (final edit in edits)
                  if (!edit.deleted) edit,
              ]);
            },
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'my_images',
          label: 'My Images',
          icon: AppIcons.tabImages,
          content: ItemImagesEditSection(
            images: [
              for (final image in request.itemImages)
                if (image.imageType != 'front_cover' &&
                    image.imageType != 'back_cover')
                  image,
            ],
            accent: request.accent,
            onChanged: (edits) => request.onItemImagesChanged?.call([
              for (final edit in edits)
                if (!edit.deleted) edit,
              for (final image in request.itemImages)
                if (_isCover(image)) _imageEdit(image),
            ]),
          ),
        ),
        LibraryAddManualPaneTab.fromSchema<GameToyAddManualDraft>(
          id: 'description',
          label: 'Description',
          icon: AppIcons.tabDescription,
          schema: LibraryFormSchema<GameToyAddManualDraft>(sections: [
            LibraryFormSectionSpec<GameToyAddManualDraft>(
              id: 'description',
              label: '',
              maxColumns: 1,
              fields: [
                LibraryTextFieldSpec<GameToyAddManualDraft>(
                  id: 'description',
                  label: 'Description',
                  maxLines: 18,
                  value: (draft) => draft.values.description,
                  setValue: (draft, value) => draft.values.description = value,
                ),
              ],
            ),
          ]),
          draft: draft,
          mediaKind: request.kind.apiValue,
          onChanged: request.onManualDraftChanged,
        ),
        LibraryAddManualPaneTab(
          id: 'links',
          label: 'Links',
          icon: AppIcons.tabLinks,
          content: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LibraryExternalLinksDraftEditor(
                    links: draft.externalLinks,
                    accent: request.accent,
                    onChanged: request.onManualDraftChanged,
                  ),
                  const SizedBox(height: 18),
                  LibraryExternalLinksDraftEditor(
                    links: draft.trailers,
                    accent: request.accent,
                    addLabel: 'Add YouTube Trailer',
                    emptyMessage: 'No YouTube trailers added.',
                    onChanged: request.onManualDraftChanged,
                  ),
                ]),
          ),
        ),
      ],
    );
  }

  Widget _purchaseDate(GameToyAddDraft personal) => LibraryFormField(
        label: 'Purchase Date',
        child: LibraryPartialDateInput(
          value: personal.purchaseDateParts ??
              (request.commonDraft?.purchaseDate == null
                  ? null
                  : PartialDate.fromDateTime(
                      request.commonDraft!.purchaseDate!)),
          onChanged: (date) {
            _update(personal.copyWith(purchaseDateParts: date));
            request.purchaseDateController.text =
                date?.asDateTime?.toIso8601String() ?? '';
            final common = request.commonDraft;
            if (common != null) {
              request.onCommonDraftChanged
                  ?.call(common.copyWith(purchaseDate: date?.asDateTime));
            }
          },
        ),
      );
}

final class _AddValueBindings implements GameToyValueBindings {
  const _AddValueBindings(this.request, this.draft);
  final LibraryAddManualPaneRequest request;
  final GameToyAddDraft draft;
  @override
  GameToyEntryDetails get details => draft.details;
  @override
  int? get valueCents => draft.marketValueCents;
  @override
  String get currency =>
      request.commonDraft?.currency ?? AppFormats.current.currency;
  @override
  void setDetails(GameToyEntryDetails details) =>
      request.onKindDraftChanged?.call(draft.copyWith(details: details));
  @override
  void setValueCents(int? value) =>
      request.onKindDraftChanged?.call(draft.copyWith(marketValueCents: value));
}

bool _isCover(ItemImageContent image) =>
    image.imageType == 'front_cover' || image.imageType == 'back_cover';

ItemImageEdit _imageEdit(ItemImageContent image) => ItemImageEdit(
      id: image.id,
      imageData: image.imageData,
      caption: image.caption,
      imageType: image.imageType,
      sortOrder: image.sortOrder,
      createdAt: image.createdAt,
    );

Widget buildGameToyAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    GameToyAddManualPane(request: request);
