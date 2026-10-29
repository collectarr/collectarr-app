import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_layout_widgets.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/host.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/person_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/people_editors.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_catalog_browse_api.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';

extension ComicCreditsTabs on ComicEditHost {
  Widget buildComicCreatorsTab() {
    return EditTabShell(
      children: [
        ComicCreatorListEditor(
          creators: comicCreators,
          accent: comicAccent,
          onAdd: () => comicMutateState(
            () => comicCreators.add(EditableComicCreator.custom()),
          ),
          onRemove: (index) => comicMutateState(
            () => comicCreators.removeAt(index).dispose(),
          ),
          onReorder: (oldIndex, newIndex) => comicMutateState(() {
            final item = comicCreators.removeAt(oldIndex);
            comicCreators.insert(newIndex, item);
          }),
          onChanged: () => comicMutateState(() {}),
          onFindInCatalog: _addCatalogComicCreator,
          onLookupCreator: _lookupComicCreatorForRow,
          roleOpenPicker: ({
            required label,
            required selectedValue,
            required options,
          }) =>
              showPickListSelectDialog(
            context: comicContext,
            label: label,
            options: options,
            selectedValue: selectedValue,
          ),
        ),
      ],
    );
  }

  Widget buildComicCharactersTab() {
    return EditTabShell(
      children: [
        ComicCharacterListEditor(
          characters: comicCharacters,
          accent: comicAccent,
          onAdd: () => comicMutateState(
            () => comicCharacters.add(EditableComicCharacter.custom('')),
          ),
          onRemove: (index) => comicMutateState(
            () => comicCharacters.removeAt(index).dispose(),
          ),
          onReorder: (oldIndex, newIndex) => comicMutateState(() {
            final item = comicCharacters.removeAt(oldIndex);
            comicCharacters.insert(newIndex, item);
          }),
          onChanged: () => comicMutateState(() {}),
          onFindInCatalog: _addCatalogComicCharacter,
        ),
      ],
    );
  }

  Future<void> _addCatalogComicCreator() async {
    final api = comicRef.read(apiClientProvider);
    final creator = await _showComicLookupDialog(
      title: 'Find creator',
      searchHint: 'Search creators',
      search: (query) =>
          ComicCatalogBrowseApi(api).searchCreators(query: query, limit: 24),
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
      search: (query) =>
          ComicCatalogBrowseApi(api).searchCreators(query: query, limit: 24),
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

  Future<void> _addCatalogComicCharacter() async {
    final api = comicRef.read(apiClientProvider);
    final character = await _showComicLookupDialog(
      title: 'Find character',
      searchHint: 'Search characters',
      search: (query) =>
          ComicCatalogBrowseApi(api).searchCharacters(query: query, limit: 24),
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

    try {
      return await showAppDialog<Map<String, dynamic>>(
        context: comicContext,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AccentAlertDialog(
                headerIcon: AppIcons.tabDetails,
                title: Text(title),
                content: SizedBox(
                  width: 620,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: LibraryTextFormControl(
                              controller: searchController,
                              decoration: InputDecoration(hintText: searchHint),
                              onFieldSubmitted: (_) =>
                                  runSearch(setDialogState),
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
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
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
    } finally {
      searchController.dispose();
    }
  }
}
