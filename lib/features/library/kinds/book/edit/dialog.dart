import 'dart:convert';

import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:collectarr_app/features/library/edit/core_correction/core_correction.dart';
import 'package:collectarr_app/features/library/edit/draft/models.dart';
import 'package:collectarr_app/features/library/edit/draft/entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/schema/renderer.dart';
import 'package:collectarr_app/features/library/edit/schema/dialog.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/covers_tab.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/schema.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/personal_form_layout.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/read_history.dart';
import 'package:collectarr_app/features/library/edit/sections/entry_personal_section.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/external_links_editor.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/formatted_text_form_control.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';

Widget buildBookItemEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _BookItemEditDialog(request: request);

final class _BookItemEditDialog extends StatefulWidget {
  const _BookItemEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_BookItemEditDialog> createState() => _BookItemEditDialogState();
}

final class _BookItemEditDialogState extends State<_BookItemEditDialog> {
  late final BookCatalogMetadata _metadata;
  late final BookItemEditDraft _draft;
  late final String _initialJson;
  late final BookReadingDraft _reading;
  late Map<String, String?> _customFieldEdits;
  late final Map<String, String?> _initialCustomFieldEdits;
  List<ItemImageEdit> _imageEdits = const [];
  List<ItemImageEdit> _coverEdits = const [];

  @override
  void initState() {
    super.initState();
    _metadata = widget.request.kindItem.kindCapability
        .mapTransport(const BookCatalogTransportCodec().decode);
    _draft = BookItemEditDraft.fromMetadata(_metadata);
    _reading = BookReadingDraft(widget.request.trackingSummary);
    // Saving fills derived values, so an untouched draft is compared with
    // its own first output rather than the stored item.
    _initialJson = jsonEncode(_draft.toMetadata().toJson());
    _initialCustomFieldEdits = {
      for (final value in widget.request.customFieldValues)
        value.fieldDefinitionId: value.value,
    };
    _customFieldEdits = Map.of(_initialCustomFieldEdits);
  }

  @override
  void dispose() {
    _draft.dispose();
    _reading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personal = LibraryEntryEditScope.maybeOf(context);
    final vocabularyEdits = personal?.vocabularyEdits ?? _draft.vocabularyEdits;
    _draft.vocabularyEdits = vocabularyEdits;
    final accent = widget.request.accent;
    return LibraryEditSchemaDialog<BookCatalogMetadata, BookItemEditDraft>(
      schema: bookItemEditSchema,
      model: _metadata,
      draft: _draft,
      maxDialogWidth: 1200,
      insetPadding: EdgeInsets.fromLTRB(
        MediaQuery.sizeOf(context).width <= 900 ? 0 : 24,
        kAppEditorTopInset,
        MediaQuery.sizeOf(context).width <= 900 ? 0 : 24,
        24,
      ),
      title: bookEditHeaderTitle(_metadata),
      mediaKind: widget.request.type.kind.apiValue,
      vocabularyAccumulator: vocabularyEdits,
      accent: accent,
      tabOrderKey: 'library_edit_tabs_book_v1',
      extraTabOrder: const [
        'personal',
        'custom_fields',
        'read_history',
        'value',
        'covers',
        'my_images',
        'plot',
        'links'
      ],
      contributions: LibraryEditSchemaContributions(
        personal: LibraryEditPersonalTabContribution(
          icon: AppIcons.tabPersonal,
          afterTabId: 'credits',
          layoutBuilder: bookPersonalFormLayout,
          additionalFieldsBuilder: (draft) => {
            ...bookPersonalAdditionalFields(draft),
            'rating': MediaRatingField(
                controller: _reading.rating, label: 'My Rating'),
          },
        ),
        customFields: LibraryEditCustomFieldsTabContribution(
          icon: AppIcons.tabCustomFields,
          definitions: widget.request.customFieldDefinitions,
          values: _customFieldEdits,
          onChanged: (values) =>
              setState(() => _customFieldEdits = Map.of(values)),
          onCustomValueChanged: (fieldDefinitionId, value) {
            final definition = widget.request.customFieldDefinitions
                .where((item) => item.id == fieldDefinitionId)
                .firstOrNull;
            _draft.vocabularyEdits.replaceValue(
              fieldId: 'custom:$fieldDefinitionId',
              listName: 'customField:$fieldDefinitionId',
              value: value,
              mediaKind:
                  definition?.mediaKind ?? widget.request.type.kind.apiValue,
            );
          },
        ),
        images: LibraryEditImagesTabContribution(
          icon: AppIcons.tabImages,
          afterTabId: 'covers',
          images: [
            for (final image in widget.request.itemImages)
              if (image.imageType != 'front_cover' &&
                  image.imageType != 'back_cover')
                image,
          ],
          onChanged: (edits) => setState(() => _imageEdits = edits),
        ),
      ),
      extraTabs: [
        if (personal != null)
          EditSchemaExtraTab(
            id: 'read_history',
            label: 'Read History',
            icon: Icons.auto_stories_outlined,
            content: BookReadHistoryTab(draft: _reading),
          ),
        if (personal != null)
          EditSchemaExtraTab(
            id: 'value',
            label: 'Value',
            icon: AppIcons.tabValue,
            content: AnimatedBuilder(
                animation: personal,
                builder: (context, _) => LibraryEntryPersonalSection(
                    draft: personal,
                    layoutBuilder: bookValueFormLayout,
                    additionalFields: bookValueAdditionalFields(personal))),
          ),
        EditSchemaExtraTab(
          id: 'covers',
          label: 'Covers',
          icon: AppIcons.tabCovers,
          content: BookCoversTab(
            searchTitle: () => _draft.values.title,
            images: [
              for (final image in widget.request.itemImages)
                if (image.imageType == 'front_cover' ||
                    image.imageType == 'back_cover')
                  image,
            ],
            coverImageUrl: _draft.values.coverImageUrl,
            originalCoverImageUrl: _metadata.coverImageUrl ?? '',
            backCoverImageUrl: _draft.values.backCoverImageUrl,
            originalBackCoverImageUrl: _metadata.backCoverImageUrl ?? '',
            onBackCoverImageUrlChanged: (value) =>
                _draft.values.backCoverImageUrl = value,
            onCoverImageUrlChanged: (value) =>
                _draft.values.coverImageUrl = value,
            onEdits: (edits) => setState(() => _coverEdits = edits),
          ),
        ),
        EditSchemaExtraTab(
          id: 'plot',
          label: 'Plot',
          icon: AppIcons.tabDescription,
          content: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: LibraryFormField(
              label: 'Plot',
              child: LibraryFormattedTextFormControl(
                initialValue: _draft.values.description,
                minLines: 18,
                maxLines: 18,
                onChanged: (value) => _draft.values.description = value,
              ),
            ),
          ),
        ),
        EditSchemaExtraTab(
          id: 'links',
          label: 'Links',
          icon: AppIcons.tabLinks,
          content: _BookLinksTab(draft: _draft, accent: accent),
        ),
      ],
      coreCorrectionSourceBuilder: () {
        final coreRef = coreCatalogRefForEditRequest(widget.request);
        const codec = BookCatalogTransportCodec();
        return LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          coreCatalogRef: coreRef,
          originalFields: codec.encode(coreRef.id, _metadata).kindData,
          proposedFields:
              codec.encode(coreRef.id, _draft.toMetadata()).kindData,
        );
      },
      onCancel: () => Navigator.of(context).pop(),
      onPrevious: widget.request.onPrevious,
      onNext: widget.request.onNext,
      hasUnsavedChanges: () =>
          _initialJson != jsonEncode(_draft.toMetadata().toJson()) ||
          _reading.hasChanges ||
          _imageEdits.isNotEmpty ||
          _coverEdits.isNotEmpty ||
          jsonEncode(_customFieldEdits) != jsonEncode(_initialCustomFieldEdits),
      onSave: (_) async {
        final updated = _draft.toMetadata();
        final candidate = personal == null
            ? widget.request.kindItem.kindCapability.mapTransport(
                (transport) => CatalogSearchCandidate.fromItem(
                  transport.replacingKindData(updated),
                  basedOn: widget.request.kindItem,
                ),
              )
            : widget.request.kindItem.kindCapability.replacingKindData(updated);
        await commitLibraryEdit(
          context,
          LibraryEditSelection(
            kindItem: candidate,
            tracking: _reading.hasChanges ? _reading.selection : null,
            customFieldEdits: Map.unmodifiable(_customFieldEdits),
            itemImageEdits: [..._imageEdits, ..._coverEdits],
            localChanges: [
              if (personal == null && !vocabularyEdits.isEmpty)
                vocabularyEdits.toEditChange(
                  defaultMediaKind: widget.request.type.kind.apiValue,
                ),
            ],
          ),
        );
      },
    );
  }
}

final class _BookLinksTab extends StatelessWidget {
  const _BookLinksTab({required this.draft, required this.accent});
  final BookItemEditDraft draft;
  final Color accent;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: BookExternalLinksEditor(
            links: draft.externalLinks, accent: accent, onChanged: () {}),
      );
}
