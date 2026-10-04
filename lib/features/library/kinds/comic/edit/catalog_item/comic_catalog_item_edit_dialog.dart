import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_link.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/catalog_item/comic_catalog_item_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_people_editors.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_person_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_values.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

Widget buildComicCatalogItemLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _ComicCatalogItemEditDialog(request: request);

class _ComicCatalogItemEditDialog extends StatefulWidget {
  const _ComicCatalogItemEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_ComicCatalogItemEditDialog> createState() =>
      _ComicCatalogItemEditDialogState();
}

class _ComicCatalogItemEditDialogState
    extends State<_ComicCatalogItemEditDialog> {
  late final ComicCatalogItem _media;
  late final ComicCatalogItemFormValues _draft;
  late final List<EditableComicCreator> _creators;
  late final List<EditableComicCharacter> _characters;
  late final List<_EditableComicExternalLink> _externalLinks;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.kindCapability
        .mapTransport((transport) => transport);
    _media = ComicCatalogItem.fromJson(transport.payload);
    _draft = comicCatalogItemFormValuesFrom(_media);
    _creators = initComicCreators(_media);
    _characters = initComicCharacters(_media);
    _externalLinks = [
      for (final link in _media.links)
        if (link.isExternalLink) _EditableComicExternalLink.fromLink(link),
    ];
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<ComicCatalogItem, ComicCatalogItemFormValues>(
        schema: comicCatalogItemEditSchema,
        model: _media,
        draft: _draft,
        title: comicCatalogItemEditSchema.title?.call(_media) ?? 'Edit comic',
        icon: widget.request.type.identity.icon,
        mediaKind: widget.request.type.kind.apiValue,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_comic_catalog_item',
        extraTabs: [
          _creatorsTab(),
          _charactersTab(),
          _linksTab(),
        ],
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
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
            ),
          );
          await commitLibraryEdit(
            context,
            LibraryEditSelection(kindItem: updated),
          );
        },
      );

  EditSchemaExtraTab _creatorsTab() => EditSchemaExtraTab(
        id: 'creators',
        label: 'Creators',
        icon: Icons.people_outline,
        content: ComicCreatorListEditor(
          creators: _creators,
          accent: widget.request.accent,
          onAdd: () => setState(
            () => _creators.add(EditableComicCreator.custom()),
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
        icon: Icons.face_outlined,
        content: ComicCharacterListEditor(
          characters: _characters,
          accent: widget.request.accent,
          onAdd: () => setState(
            () => _characters.add(EditableComicCharacter.custom('')),
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
        icon: Icons.public,
        content: LibraryExternalLinksTable<_EditableComicExternalLink>(
          rows: [
            for (final link in _externalLinks)
              LibraryExternalLinkEditRow<_EditableComicExternalLink>(
                identity: link,
                urlController: link.urlController,
                descriptionController: link.descriptionController,
              ),
          ],
          accent: widget.request.accent,
          addLabel: 'New Link',
          onAdd: () => setState(
            () => _externalLinks.add(_EditableComicExternalLink()),
          ),
          onReorder: _reorderLinks,
          onRemoveSelected: (rows) => setState(() {
            for (final row in rows) {
              if (_externalLinks.remove(row.identity)) row.identity.dispose();
            }
          }),
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
            if (link.urlController.text.trim().isNotEmpty) link.toModel(),
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

  void _reorderLinks(int oldIndex, int newIndex) => setState(() {
        final link = _externalLinks.removeAt(oldIndex);
        _externalLinks.insert(newIndex, link);
      });

  void _onDraftChanged() {
    if (mounted) setState(() {});
  }
}

final class _EditableComicExternalLink {
  _EditableComicExternalLink({ComicLink? original})
      : original = original ??
            const ComicLink(
              url: '',
              source: 'manual',
              isAutomatic: false,
              kind: 'external',
            ),
        urlController = TextEditingController(text: original?.url ?? ''),
        descriptionController = TextEditingController(
          text: original?.description ?? original?.title ?? '',
        );

  factory _EditableComicExternalLink.fromLink(ComicLink link) =>
      _EditableComicExternalLink(original: link);

  final ComicLink original;
  final TextEditingController urlController;
  final TextEditingController descriptionController;

  ComicLink toModel() => ComicLink(
        url: urlController.text.trim(),
        title: original.title,
        description: _nullable(descriptionController.text),
        source: original.source,
        isAutomatic: original.isAutomatic,
        kind: original.kind,
      );

  void dispose() {
    urlController.dispose();
    descriptionController.dispose();
  }
}

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
