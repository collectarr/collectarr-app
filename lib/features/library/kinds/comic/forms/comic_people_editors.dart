import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_creator_roles.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_person_draft.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_named_detail_list.dart';
import 'package:flutter/material.dart';

final class ComicCreatorListEditor extends StatelessWidget {
  const ComicCreatorListEditor({
    super.key,
    required this.creators,
    required this.accent,
    required this.onAdd,
    required this.onRemove,
    required this.onReorder,
    required this.onChanged,
    this.onFindInCatalog,
    this.onLookupCreator,
    this.roleOpenPicker,
  });

  final List<EditableComicCreator> creators;
  final Color accent;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onChanged;
  final VoidCallback? onFindInCatalog;
  final ValueChanged<int>? onLookupCreator;
  final LibraryDropdownPickHandler? roleOpenPicker;

  @override
  Widget build(BuildContext context) => LibraryNamedDetailList(
        title: 'Creators',
        emptyMessage: 'No creator credits yet.',
        addLabel: 'Add Creator',
        accent: accent,
        removeTooltip: 'Remove creator',
        rows: () => [
          for (final creator in creators)
            LibraryNamedDetailControllers(
              identity: creator,
              name: creator.nameController,
              detail: creator.roleController,
            ),
        ],
        detailFieldBuilder: (context, index, row) {
          final creator = creators[index];
          final currentRole = creator.roleController.text.trim();
          final roles = <String>[
            if (currentRole.isNotEmpty &&
                !kComicCreatorRoles.contains(currentRole))
              currentRole,
            ...kComicCreatorRoles,
          ];
          return LibraryDropdownPickField<String>(
            label: 'Role',
            value: currentRole.isEmpty ? null : currentRole,
            options: [
              for (final role in roles)
                LibraryFieldOption(value: role, label: role),
            ],
            allowCustomValue: true,
            openPicker: roleOpenPicker,
            onChanged: (value) {
              creator.roleController.text = value ?? '';
              onChanged();
            },
          );
        },
        headerActions: [
          if (onFindInCatalog != null)
            OutlinedButton.icon(
              onPressed: onFindInCatalog,
              icon: const Icon(Icons.person_search_outlined, size: 16),
              label: const Text('Find in Catalog'),
            ),
        ],
        rowActionsBuilder: onLookupCreator == null
            ? null
            : (context, index, row) => IconButton(
                  onPressed: () => onLookupCreator!(index),
                  icon: const Icon(Icons.person_search, size: 18),
                  tooltip: 'Lookup creator',
                ),
        detailsBuilder: (context, index, row) {
          final creator = creators[index];
          return ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: const Text('Additional creator details'),
            children: [
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: creator.creditedNameController,
                  label: 'Credited Name',
                  onChanged: (_) => onChanged(),
                ),
                LibraryEditTextField(
                  controller: creator.sortNameController,
                  label: 'Sort Name',
                  onChanged: (_) => onChanged(),
                ),
                LibraryEditTextField(
                  controller: creator.joinPhraseController,
                  label: 'Join Phrase',
                  onChanged: (_) => onChanged(),
                ),
                LibraryEditTextField(
                  controller: creator.imageUrlController,
                  label: 'Image URL',
                  onChanged: (_) => onChanged(),
                ),
              ]),
            ],
          );
        },
        onAdd: onAdd,
        onRemove: onRemove,
        onReorder: onReorder,
        onChanged: onChanged,
      );
}

final class ComicCharacterListEditor extends StatelessWidget {
  const ComicCharacterListEditor({
    super.key,
    required this.characters,
    required this.accent,
    required this.onAdd,
    required this.onRemove,
    required this.onReorder,
    required this.onChanged,
    this.onFindInCatalog,
  });

  final List<EditableComicCharacter> characters;
  final Color accent;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onChanged;
  final VoidCallback? onFindInCatalog;

  @override
  Widget build(BuildContext context) => LibraryNamedDetailList(
        title: 'Characters',
        emptyMessage: 'No characters added yet.',
        addLabel: 'Add Character',
        nameLabel: 'Character',
        detailLabel: 'Real name',
        accent: accent,
        removeTooltip: 'Remove character',
        rows: () => [
          for (final character in characters)
            LibraryNamedDetailControllers(
              identity: character,
              name: character.nameController,
              detail: character.realNameController,
            ),
        ],
        headerActions: [
          if (onFindInCatalog != null)
            OutlinedButton.icon(
              onPressed: onFindInCatalog,
              icon: const Icon(Icons.person_search_outlined, size: 16),
              label: const Text('Find in Catalog'),
            ),
        ],
        detailsBuilder: (context, index, row) {
          final character = characters[index];
          return ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: const Text('Additional character details'),
            children: [
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: character.aliasesController,
                  label: 'Aliases',
                  maxLines: 2,
                  onChanged: (_) => onChanged(),
                ),
                LibraryEditTextField(
                  controller: character.roleController,
                  label: 'Role',
                  onChanged: (_) => onChanged(),
                ),
                LibraryEditTextField(
                  controller: character.descriptionController,
                  label: 'Description',
                  maxLines: 2,
                  onChanged: (_) => onChanged(),
                ),
                LibraryEditTextField(
                  controller: character.imageUrlController,
                  label: 'Image URL',
                  onChanged: (_) => onChanged(),
                ),
              ]),
            ],
          );
        },
        onAdd: onAdd,
        onRemove: onRemove,
        onReorder: onReorder,
        onChanged: onChanged,
      );
}
