import 'package:collectarr_app/features/library/edit/session/catalog_edit_changes.dart';

import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:collectarr_app/features/library/edit/core_correction/core_correction.dart';
import 'package:collectarr_app/features/library/edit/draft/entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/schema/renderer.dart';
import 'package:collectarr_app/features/library/edit/schema/dialog.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_read_event.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
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
  late final LibraryCatalogEditChanges _changes;
  BookReadingDraft? _readingDraft;
  BookReadingDraft get _reading => _readingDraft!;

  @override
  void initState() {
    super.initState();
    _metadata = widget.request.kindItem.kindCapability
        .mapTransport(const BookCatalogTransportCodec().decode);
    _draft = BookItemEditDraft.fromMetadata(_metadata);
    // Saving fills derived values, so an untouched draft is compared with
    // its own first output rather than the stored item.
    _changes = LibraryCatalogEditChanges(
      initialCatalogFields: _draft.toMetadata().toJson(),
      customFieldValues: widget.request.customFieldValues,
    );
  }

  @override
  void dispose() {
    _draft.dispose();
    _readingDraft?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personal = LibraryEntryEditScope.maybeOf(context);
    _readingDraft ??= BookReadingDraft(
      widget.request.trackingSummary,
      events: BookReadEvent.listFromJson(personal?.values['read_events']),
    );
    _reading.pageCount = _draft.values.pageCount;
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
            'rating': LibraryFormField(
              label: 'My Rating',
              child: MediaRatingField(
                  controller: _reading.rating, showLabel: false, compact: true),
            ),
          },
        ),
        customFields: LibraryEditCustomFieldsTabContribution(
          icon: AppIcons.tabCustomFields,
          definitions: widget.request.customFieldDefinitions,
          values: _changes.customFields,
          onChanged: (values) =>
              setState(() => _changes.customFields = Map.of(values)),
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
          onChanged: (edits) => setState(() => _changes.images = edits),
        ),
      ),
      extraTabs: [
        if (personal != null)
          EditSchemaExtraTab(
            id: 'read_history',
            label: 'Read History',
            icon: AppIcons.bookReader,
            content: BookReadHistoryTab(
              draft: _reading,
              onChanged: () {
                personal.set('read_events', _reading.eventsJson);
                for (final (index, event) in _reading.events.indexed) {
                  personal.vocabularyEdits.replaceValue(
                    fieldId: 'personal:read_events:$index',
                    listName: BookVocabularyIds.reader.value,
                    value: event.reader,
                    mediaKind: widget.request.type.kind.apiValue,
                  );
                }
              },
            ),
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
            onEdits: (edits) => setState(() => _changes.covers = edits),
          ),
        ),
        EditSchemaExtraTab(
          id: 'plot',
          label: 'Plot',
          icon: AppIcons.tabDescription,
          content: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: LibraryFormattedTextFormControl(
              initialValue: _draft.values.description,
              minLines: 18,
              maxLines: 18,
              onChanged: (value) => _draft.values.description = value,
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
          _changes.hasChanges(_draft.toMetadata().toJson()) ||
          _reading.hasChanges,
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
          _changes.selection(
            kindItem: candidate,
            tracking: _reading.hasChanges ? _reading.selection : null,
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
