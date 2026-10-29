import 'package:collectarr_app/ui/app_icons.dart';
import 'dart:convert';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/sections/library_entry_personal_section.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import '../domain/comic_personal_data.dart';
import 'entry_draft.dart';
import 'covers_tab.dart';
import 'personal_form.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_draft_editor.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_creator.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_character.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_link.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/people_editors.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/person_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/catalog_form_values.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

Widget buildComicItemEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    ComicItemEditDialog(request: request);

class ComicItemEditDialog extends StatefulWidget {
  const ComicItemEditDialog({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<ComicItemEditDialog> createState() => _ComicItemEditDialogState();
}

class _ComicItemEditDialogState extends State<ComicItemEditDialog> {
  late final ComicCatalogItem _media;
  late final String _initialJson;
  ComicEntryEditDraft? _entry;
  late Map<String, String?> _customFieldEdits;
  late final String _initialCustomJson;
  List<ItemImageEdit> _imageEdits = const [];
  List<ItemImageEdit> _coverEdits = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final personal = LibraryEntryEditScope.maybeOf(context);
    if (personal != null && _entry == null) {
      _entry = ComicEntryEditDraft.fromDetails(
          ComicPersonalData.fromJson(personal.values).details);
    }
  }

  late final ComicCatalogItemFormValues _draft;
  late final List<EditableComicCreator> _creators;
  late final List<EditableComicCharacter> _characters;
  late final List<LibraryExternalLinkDraftRow> _externalLinks;
  late final Map<LibraryExternalLinkDraftRow, ComicLink> _originalExternalLinks;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.kindCapability
        .mapTransport((transport) => transport);
    _media = ComicCatalogItem.fromJson(transport.payload);
    _draft = comicCatalogItemFormValuesFrom(_media);
    _customFieldEdits = {
      for (final value in widget.request.customFieldValues)
        value.fieldDefinitionId: value.value
    };
    _initialCustomJson = jsonEncode(_customFieldEdits);
    _creators = initComicCreators(_media);
    _characters = initComicCharacters(_media);
    _externalLinks = [];
    _originalExternalLinks = {};
    for (final link in _media.links.where((link) => link.isExternalLink)) {
      final row = LibraryExternalLinkDraftRow(
        title: link.title ?? '',
        url: link.url,
        description: link.description ?? '',
      );
      _externalLinks.add(row);
      _originalExternalLinks[row] = link;
    }
    _initialJson = jsonEncode(_editedMedia().toJson());
  }

  @override
  void dispose() {
    for (final creator in _creators) {
      creator.dispose();
    }
    for (final character in _characters) {
      character.dispose();
    }
    for (final link in _externalLinks) {
      link.dispose();
    }
    _entry?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<ComicCatalogItem, ComicCatalogItemFormValues>(
        schema: comicCatalogItemEditSchema,
        model: _media,
        maxDialogWidth: 1200,
        insetPadding: EdgeInsets.fromLTRB(
          MediaQuery.sizeOf(context).width <= 900 ? 0 : 24,
          kAppEditorTopInset,
          MediaQuery.sizeOf(context).width <= 900 ? 0 : 24,
          24,
        ),
        draft: _draft,
        title: comicCatalogItemEditSchema.title?.call(_media) ?? 'Edit comic',
        icon: widget.request.type.identity.icon,
        mediaKind: widget.request.type.kind.apiValue,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_comic_typed',
        hasUnsavedChanges: () =>
            _initialJson != jsonEncode(_editedMedia().toJson()) ||
            _imageEdits.isNotEmpty ||
            _coverEdits.isNotEmpty ||
            _initialCustomJson != jsonEncode(_customFieldEdits),
        extraTabs: [
          if (LibraryEntryEditScope.maybeOf(context) case final personal?) ...[
            _personalTab(personal, valueTab: true),
            _personalTab(personal, valueTab: false),
          ],
          EditSchemaExtraTab(
              id: 'custom_fields',
              label: 'Custom Fields',
              icon: AppIcons.tabCustomFields,
              content: CustomFieldsEditSection(
                definitions: widget.request.customFieldDefinitions,
                values: _customFieldEdits,
                accent: widget.request.accent,
                mediaKind: 'comic',
                onChanged: (values) =>
                    setState(() => _customFieldEdits = Map.of(values)),
              )),
          EditSchemaExtraTab(
              id: 'covers',
              label: 'Covers',
              icon: AppIcons.tabCovers,
              content: ComicCoversTab(
                images: [
                  for (final image in widget.request.itemImages)
                    if (_isCover(image)) image
                ],
                coverImageUrl: _draft.coverImageUrl,
                originalCoverImageUrl: _media.coverImageUrl ?? '',
                onCoverImageUrlChanged: (value) => _draft.coverImageUrl = value,
                onEdits: (edits) => setState(() => _coverEdits = edits),
                searchTitle: () => _draft.seriesTitle,
              )),
          EditSchemaExtraTab(
              id: 'my_images',
              label: 'My Images',
              icon: AppIcons.tabImages,
              content: ItemImagesEditSection(
                images: [
                  for (final image in widget.request.itemImages)
                    if (!_isCover(image)) image
                ],
                accent: widget.request.accent,
                onChanged: (edits) => setState(() => _imageEdits = edits),
              )),
          _creatorsTab(),
          _charactersTab(),
          EditSchemaExtraTab(
              id: 'plot',
              label: 'Plot',
              icon: AppIcons.tabDescription,
              content: LibraryTextFormControl(
                initialValue: _draft.description,
                minLines: 18,
                maxLines: 18,
                onChanged: (value) => _draft.description = value,
              )),
          _linksTab(),
        ],
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          coreCatalogRef: coreCatalogRefForEditRequest(widget.request),
          originalFields: _media.toJson(),
          proposedFields: _editedMedia().toJson(),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        onSave: (_) async {
          final updatedMedia = _editedMedia();
          final updated = widget.request.kindItem.kindCapability.mapTransport(
            (transport) => CatalogSearchCandidate.fromItem(
              transport.replacingKindData(updatedMedia),
              basedOn: widget.request.kindItem,
            ),
          );
          await commitLibraryEdit(
            context,
            LibraryEditSelection(
                kindItem: updated,
                customFieldEdits: Map.unmodifiable(_customFieldEdits),
                itemImageEdits: [..._imageEdits, ..._coverEdits]),
          );
        },
      );

  EditSchemaExtraTab _personalTab(LibraryEntryEditDraft draft,
          {required bool valueTab}) =>
      EditSchemaExtraTab(
        id: valueTab ? 'value' : 'personal',
        label: valueTab ? 'Value' : 'Personal',
        icon: valueTab ? AppIcons.tabValue : AppIcons.tabPersonal,
        content: AnimatedBuilder(
          animation: draft,
          builder: (context, _) => LibraryEntryPersonalSection(
            draft: draft,
            layoutBuilder: (fields, _) => ComicPersonalForm(
              personal: ComicPersonalData.fromJson(draft.values),
              entry: _entry!,
              valueTab: valueTab,
              currency: draft.text('currency').isEmpty
                  ? 'USD'
                  : draft.text('currency'),
              commonFields: fields,
              update: (value) {
                final previous =
                    ComicPersonalData.fromJson(draft.values).toJson();
                final next = value.toJson();
                for (final key in {...previous.keys, ...next.keys}) {
                  if (jsonEncode(previous[key]) != jsonEncode(next[key])) {
                    draft.set(key, next[key]);
                  }
                }
              },
            ),
          ),
        ),
      );

  EditSchemaExtraTab _creatorsTab() => EditSchemaExtraTab(
        id: 'creators',
        label: 'Creators',
        icon: AppIcons.tabCredits,
        content: ComicCreatorListEditor(
          creators: _creators,
          accent: widget.request.accent,
          onAdd: () => setState(
            () => _creators.add(EditableComicCreator.blank()),
          ),
          onRemove: (index) =>
              setState(() => _creators.removeAt(index).dispose()),
          onReorder: _reorderCreators,
          onChanged: _onDraftChanged,
        ),
      );

  EditSchemaExtraTab _charactersTab() => EditSchemaExtraTab(
        id: 'characters',
        label: 'Characters',
        icon: AppIcons.tabPersonal,
        content: ComicCharacterListEditor(
          characters: _characters,
          accent: widget.request.accent,
          onAdd: () => setState(
            () => _characters.add(EditableComicCharacter.blank()),
          ),
          onRemove: (index) =>
              setState(() => _characters.removeAt(index).dispose()),
          onReorder: _reorderCharacters,
          onChanged: _onDraftChanged,
        ),
      );

  EditSchemaExtraTab _linksTab() => EditSchemaExtraTab(
        id: 'links',
        label: 'Links',
        icon: AppIcons.tabLinks,
        content: LibraryExternalLinksDraftEditor(
          links: _externalLinks,
          accent: widget.request.accent,
          onChanged: _onDraftChanged,
        ),
      );

  ComicCatalogItem _editedMedia() => comicCatalogItemFromFormValues(
        original: _media,
        values: _draft,
        creators: [
          for (final creator in _creators)
            if (creator.nameController.text.trim().isNotEmpty)
              ComicCreator.fromValue(creator.toMap()),
        ],
        characters: [
          for (final character in _characters)
            if (character.nameController.text.trim().isNotEmpty)
              ComicCharacter.fromValue(character.toMap()),
        ],
        externalLinks: [
          for (final link in _media.links)
            if (!link.isExternalLink) link,
          for (final link in _externalLinks)
            if (link.urlController.text.trim().isNotEmpty)
              _comicLinkFromDraft(link),
        ],
      );

  void _reorderCreators(int oldIndex, int newIndex) => setState(() {
        final creator = _creators.removeAt(oldIndex);
        _creators.insert(newIndex, creator);
      });

  void _reorderCharacters(int oldIndex, int newIndex) => setState(() {
        final character = _characters.removeAt(oldIndex);
        _characters.insert(newIndex, character);
      });

  ComicLink _comicLinkFromDraft(LibraryExternalLinkDraftRow row) {
    final original = _originalExternalLinks[row];
    return ComicLink(
      url: row.urlController.text.trim(),
      title: _nullable(row.titleController.text),
      description: _nullable(row.descriptionController.text),
      source: original?.source ?? 'manual',
      isAutomatic: original?.isAutomatic ?? false,
      kind: original?.kind ?? 'external',
    );
  }

  void _onDraftChanged() {
    if (mounted) setState(() {});
  }
}

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

bool _isCover(ItemImageContent image) =>
    image.imageType == 'front_cover' || image.imageType == 'back_cover';
