import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_names_field.dart';
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

  @override
  void initState() {
    super.initState();
    _characters = List.of(widget.characters);
  }

  @override
  void didUpdateWidget(covariant MovieCharactersEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.characters, widget.characters)) {
      _characters = List.of(widget.characters);
    }
  }

  String _identity(int index, MovieCharacter character) =>
      character.id ?? 'character-$index';

  @override
  Widget build(BuildContext context) => LibraryOrderedNamesField(
        label: 'Characters',
        values: [
          for (var index = 0; index < _characters.length; index++)
            LibraryNamedValue(
              id: _identity(index, _characters[index]),
              name: _characters[index].name,
            ),
        ],
        onChanged: (values) {
          final previous = <String, MovieCharacter>{
            for (var index = 0; index < _characters.length; index++)
              _identity(index, _characters[index]): _characters[index],
          };
          final next = [
            for (final value in values)
              _characterFor(value, previous[value.id]),
          ];
          setState(() => _characters = next);
          widget.onChanged(next);
        },
      );

  MovieCharacter _characterFor(
    LibraryNamedValue value,
    MovieCharacter? previous,
  ) =>
      MovieCharacter(
        id: previous?.id ?? (previous == null ? value.id : null),
        characterId: previous?.characterId,
        name: value.name,
        aliases: previous?.aliases ?? const [],
        role: previous?.role,
        description: previous?.description,
        imageUrl: previous?.imageUrl,
      );
}
