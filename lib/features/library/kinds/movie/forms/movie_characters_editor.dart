import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Ordered character names shared by Movie Manual Add and Edit.
class MovieCharactersEditor extends StatefulWidget {
  const MovieCharactersEditor({
    super.key,
    required this.characters,
    required this.onChanged,
  });

  final List<MovieCharacter> characters;
  final ValueChanged<List<MovieCharacter>> onChanged;

  @override
  State<MovieCharactersEditor> createState() => _MovieCharactersEditorState();
}

class _MovieCharactersEditorState extends State<MovieCharactersEditor> {
  late List<MovieCharacter> _characters;
  final Set<String> _expandedCharacters = {};

  @override
  void initState() {
    super.initState();
    _characters = [
      for (var index = 0; index < widget.characters.length; index++)
        _withIdentity(widget.characters[index], index),
    ];
  }

  @override
  void didUpdateWidget(covariant MovieCharactersEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.characters, widget.characters)) {
      _characters = [
        for (var index = 0; index < widget.characters.length; index++)
          _withIdentity(widget.characters[index], index),
      ];
    }
  }

  String _identity(int index, MovieCharacter character) =>
      character.id ?? 'character-$index';

  MovieCharacter _withIdentity(MovieCharacter character, int index) =>
      character.id != null
          ? character
          : _copyWith(
              character,
              id: 'movie-character-${DateTime.now().microsecondsSinceEpoch}-$index',
            );

  void _addCharacter() {
    final identity =
        'manual-character-${DateTime.now().microsecondsSinceEpoch}';
    final next = [
      ..._characters,
      MovieCharacter(id: identity, name: ''),
    ];
    setState(() {
      _characters = next;
      _expandedCharacters.add(identity);
    });
    widget.onChanged(next);
  }

  void _removeCharacter(int index) {
    final character = _characters[index];
    final next = [..._characters]..removeAt(index);
    setState(() {
      _characters = next;
      _expandedCharacters.remove(_identity(index, character));
    });
    widget.onChanged(next);
  }

  void _updateCharacter(int index, MovieCharacter character) {
    final next = [..._characters]..[index] = character;
    setState(() => _characters = next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) => LibraryFormField(
        label: 'Characters',
        action: SizedBox(
          width: 24,
          height: 20,
          child: IconButton(
            tooltip: 'Add character',
            padding: EdgeInsets.zero,
            onPressed: _addCharacter,
            icon: const Icon(Icons.add, size: 18),
          ),
        ),
        child: _characters.isEmpty
            ? SizedBox(
                height: kLibraryFormControlHeight,
                child: OutlinedButton(
                  onPressed: _addCharacter,
                  child: const SizedBox.expand(),
                ),
              )
            : ReorderableListView.builder(
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: _characters.length,
                onReorderItem: (oldIndex, newIndex) {
                  final next = [..._characters];
                  next.insert(newIndex, next.removeAt(oldIndex));
                  setState(() => _characters = next);
                  widget.onChanged(next);
                },
                itemBuilder: (context, index) {
                  final character = _characters[index];
                  final identity = _identity(index, character);
                  final isExpanded = _expandedCharacters.contains(identity);
                  return Padding(
                    key: ValueKey(identity),
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: Icon(
                                Icons.drag_indicator,
                                size: 18,
                                color: appPalette(context).textMuted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: TextFormField(
                                key: ValueKey('$identity-name'),
                                initialValue: character.name,
                                decoration: const InputDecoration(
                                  hintText: 'Character name',
                                  constraints: BoxConstraints(
                                    minHeight: kLibraryFormControlHeight,
                                  ),
                                ),
                                onChanged: (name) => _updateCharacter(
                                  index,
                                  _copyWith(character, name: name),
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: isExpanded
                                  ? 'Hide character details'
                                  : 'Edit character details',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => setState(() {
                                if (isExpanded) {
                                  _expandedCharacters.remove(identity);
                                } else {
                                  _expandedCharacters.add(identity);
                                }
                              }),
                              icon: Icon(
                                isExpanded ? Icons.expand_less : Icons.tune,
                                size: 18,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove character',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _removeCharacter(index),
                              icon: const Icon(Icons.close, size: 18),
                            ),
                          ],
                        ),
                        if (isExpanded)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(26, 6, 0, 4),
                            child: Column(
                              children: [
                                _detailField(
                                  identity: identity,
                                  label: 'Aliases',
                                  value: character.aliases.join(', '),
                                  onChanged: (value) => _updateCharacter(
                                    index,
                                    _copyWith(
                                      character,
                                      aliases: value
                                          .split(',')
                                          .map((alias) => alias.trim())
                                          .where((alias) => alias.isNotEmpty)
                                          .toList(growable: false),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _detailField(
                                  identity: identity,
                                  label: 'Role',
                                  value: character.role ?? '',
                                  onChanged: (value) => _updateCharacter(
                                    index,
                                    _copyWith(
                                      character,
                                      role: value,
                                      clearRole: value.trim().isEmpty,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _detailField(
                                  identity: identity,
                                  label: 'Description',
                                  value: character.description ?? '',
                                  maxLines: 3,
                                  onChanged: (value) => _updateCharacter(
                                    index,
                                    _copyWith(
                                      character,
                                      description: value,
                                      clearDescription: value.trim().isEmpty,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _detailField(
                                  identity: identity,
                                  label: 'Image URL',
                                  value: character.imageUrl ?? '',
                                  onChanged: (value) => _updateCharacter(
                                    index,
                                    _copyWith(
                                      character,
                                      imageUrl: value,
                                      clearImageUrl: value.trim().isEmpty,
                                    ),
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
      );

  Widget _detailField({
    required String identity,
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
  }) =>
      LibraryFormField(
        label: label,
        child: TextFormField(
          key: ValueKey('character-detail-$identity-$label'),
          initialValue: value,
          maxLines: maxLines,
          decoration: InputDecoration(
            constraints: const BoxConstraints(
              minHeight: kLibraryFormControlHeight,
            ),
          ),
          onChanged: onChanged,
        ),
      );

  MovieCharacter _copyWith(
    MovieCharacter character, {
    String? id,
    String? name,
    List<String>? aliases,
    String? role,
    bool clearRole = false,
    String? description,
    bool clearDescription = false,
    String? imageUrl,
    bool clearImageUrl = false,
  }) =>
      MovieCharacter(
        id: id ?? character.id,
        characterId: character.characterId,
        name: name ?? character.name,
        aliases: aliases ?? character.aliases,
        role: clearRole ? null : role ?? character.role,
        description:
            clearDescription ? null : description ?? character.description,
        imageUrl: clearImageUrl ? null : imageUrl ?? character.imageUrl,
      );
}
