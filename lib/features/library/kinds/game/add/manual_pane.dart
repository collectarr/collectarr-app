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
import 'package:collectarr_app/features/library/kinds/game/add/draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_valuation.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/covers_tab.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/personal_form_layout.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/value_tab.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';

class GameAddManualPane extends StatefulWidget {
  const GameAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  State<GameAddManualPane> createState() => _GameAddManualPaneState();
}

class _GameAddManualPaneState extends State<GameAddManualPane> {
  late final TextEditingController _rating;

  LibraryAddManualPaneRequest get request => widget.request;
  GameAddDraft get _personal => request.kindDraft is GameAddDraft
      ? request.kindDraft as GameAddDraft
      : const GameAddDraft();

  void _update(GameAddDraft value) => request.onKindDraftChanged?.call(value);

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
    final draft = request.manualDraftAs<GameAddManualDraft>();
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
        LibraryAddManualPaneTab.fromSchema<GameAddManualDraft>(
          id: 'main',
          label: 'Main',
          icon: AppIcons.gamepad,
          schema: gameAddSchema,
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
            layoutBuilder: gameValueLayout,
            fieldOverrides: {
              ...gameValueFields(_AddValueBindings(request, personal, draft)),
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
            layoutBuilder: gamePersonalFormLayout,
            fieldOverrides: {
              ...gamePersonalFields(_AddPersonalBindings(request, personal)),
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
            mediaKind: 'game',
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
          label: 'Covers',
          icon: AppIcons.tabCovers,
          content: GameCoversTab(
            searchTitle: () => draft.values.title,
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
        LibraryAddManualPaneTab.fromSchema<GameAddManualDraft>(
          id: 'description',
          label: 'Description',
          icon: AppIcons.tabDescription,
          schema: LibraryFormSchema<GameAddManualDraft>(sections: [
            LibraryFormSectionSpec<GameAddManualDraft>(
              id: 'description',
              label: '',
              maxColumns: 1,
              fields: [
                LibraryTextFieldSpec<GameAddManualDraft>(
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

  Widget _purchaseDate(GameAddDraft personal) => LibraryPartialDateField(
        label: 'Purchase Date',
        value: personal.purchaseDateParts ??
            (request.commonDraft?.purchaseDate == null
                ? null
                : PartialDate.fromDateTime(request.commonDraft!.purchaseDate!)),
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
      );
}

final class _AddValueBindings implements GameValueBindings {
  const _AddValueBindings(this.request, this.draft, this.manual);

  final LibraryAddManualPaneRequest request;
  final GameAddDraft draft;
  final GameAddManualDraft manual;

  void _details(GameAddDraft Function() next) =>
      request.onKindDraftChanged?.call(next());

  @override
  String? get completeness => draft.details.completeness;
  @override
  bool get hasBox => draft.details.hasBox ?? false;
  @override
  bool get hasManual => draft.details.hasManual ?? false;
  @override
  int? get valueCents => draft.marketValueCents;
  @override
  bool get valueLocked => draft.details.valueIsLocked ?? false;
  @override
  String? get condition => request.commonDraft?.condition;
  @override
  String? get priceChartingId => draft.details.priceChartingId;
  @override
  GameValuationSet? get valuations => draft.details.valuations;
  @override
  String get currency =>
      request.commonDraft?.currency ?? AppFormats.current.currency;
  @override
  String get marketQuery => '${manual.values.title} ${manual.values.platform}';

  @override
  void setCompleteness(String? value) =>
      _details(() => draft.selectCompleteness(value));
  @override
  void setHasBox(bool value) => _details(() => draft.selectPackaging(
      hasBox: value, hasManual: hasManual, currency: currency));
  @override
  void setHasManual(bool value) => _details(() => draft.selectPackaging(
      hasBox: hasBox, hasManual: value, currency: currency));
  @override
  void setValueCents(int? value) =>
      _details(() => draft.copyWith(marketValueCents: value));
  @override
  void setValueLocked(bool value) => _details(() =>
      draft.copyWith(details: draft.details.copyWith(valueIsLocked: value)));
  @override
  void setCondition(String? value) {
    final common = request.commonDraft;
    if (common != null) {
      request.onCommonDraftChanged?.call(common.copyWith(condition: value));
    }
    request.onVocabularyValueChanged?.call(
        fieldId: 'condition',
        listName: GameVocabularyIds.condition.value,
        value: value);
  }

  @override
  void setPriceChartingId(String? value) => _details(() =>
      draft.copyWith(details: draft.details.copyWith(priceChartingId: value)));
}

final class _AddPersonalBindings implements GamePersonalBindings {
  const _AddPersonalBindings(this.request, this.draft);

  final LibraryAddManualPaneRequest request;
  final GameAddDraft draft;

  void _set(GameAddDraft value) => request.onKindDraftChanged?.call(value);

  @override
  String? get storageDevice => draft.details.storageDevice;
  @override
  String? get storageSlot => draft.details.storageSlot;
  @override
  bool get completed => draft.details.completed ?? false;
  @override
  PartialDate? get completedDate => draft.details.completedDate;

  @override
  void setStorageDevice(String? value) {
    _set(draft.copyWith(details: draft.details.copyWith(storageDevice: value)));
    request.onVocabularyValueChanged?.call(
        fieldId: 'game_storage_device',
        listName: GameVocabularyIds.storageDevice.value,
        value: value);
  }

  @override
  void setStorageSlot(String? value) =>
      _set(draft.copyWith(details: draft.details.copyWith(storageSlot: value)));
  @override
  void setCompleted(bool value) =>
      _set(draft.copyWith(details: draft.details.copyWith(completed: value)));
  @override
  void setCompletedDate(PartialDate? value) => _set(
      draft.copyWith(details: draft.details.copyWith(completedDate: value)));
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

Widget buildGameAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    GameAddManualPane(request: request);
