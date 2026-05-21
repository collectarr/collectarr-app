import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterDetailPage extends ConsumerStatefulWidget {
  const CharacterDetailPage({
    super.key,
    required this.characterName,
  });

  final String characterName;

  @override
  ConsumerState<CharacterDetailPage> createState() =>
      _CharacterDetailPageState();
}

class _CharacterDetailPageState extends ConsumerState<CharacterDetailPage> {
  late Future<_CharacterDetailData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_CharacterDetailData> _load() async {
    final api = ref.read(apiClientProvider);
    final results = await api.searchCharacters(
      query: widget.characterName,
      limit: 12,
    );
    if (results.isEmpty) {
      throw StateError('No character metadata found for ${widget.characterName}.');
    }
    final character = _pickBestCharacter(results, widget.characterName);
    final appearances = await api.getCharacterAppearances(
      character['id'].toString(),
    );
    return _CharacterDetailData(
      character: character,
      appearances: appearances,
      alternatives: results,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.characterName),
      ),
      body: FutureBuilder<_CharacterDetailData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _CharacterDetailError(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final data = snapshot.data!;
          return _CharacterDetailBody(data: data);
        },
      ),
    );
  }
}

class _CharacterDetailData {
  const _CharacterDetailData({
    required this.character,
    required this.appearances,
    required this.alternatives,
  });

  final Map<String, dynamic> character;
  final List<Map<String, dynamic>> appearances;
  final List<Map<String, dynamic>> alternatives;
}

class _CharacterDetailBody extends StatelessWidget {
  const _CharacterDetailBody({required this.data});

  final _CharacterDetailData data;

  @override
  Widget build(BuildContext context) {
    final character = data.character;
    final aliases = (character['aliases'] as List<dynamic>? ?? const [])
        .map((value) => value.toString())
        .where((value) => value.trim().isNotEmpty)
        .toList(growable: false);
    final description = character['description']?.toString();
    final imageUrl = character['image_url']?.toString();
    final appearanceCount = (character['appearance_count'] as num?)?.toInt() ??
        data.appearances.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CharacterPortrait(imageUrl: imageUrl),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character['name']?.toString() ?? 'Character',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaStatChip(
                        icon: Icons.auto_stories_outlined,
                        label: '$appearanceCount appearances',
                      ),
                      if (aliases.isNotEmpty)
                        _MetaStatChip(
                          icon: Icons.badge_outlined,
                          label: '${aliases.length} aliases',
                        ),
                    ],
                  ),
                  if (aliases.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Aliases',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final alias in aliases) _AliasChip(alias: alias),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (description != null && description.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(description),
        ],
        const SizedBox(height: 20),
        Text(
          'Appearances',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (data.appearances.isEmpty)
          const Text('No appearance records were returned for this character.')
        else
          for (final appearance in data.appearances)
            _CharacterAppearanceTile(appearance: appearance),
      ],
    );
  }
}

class _CharacterPortrait extends StatelessWidget {
  const _CharacterPortrait({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 120,
        height: 160,
        child: imageUrl == null || imageUrl!.trim().isEmpty
            ? const ColoredBox(
                color: Color(0x22000000),
                child: Icon(Icons.groups_2_outlined, size: 42),
              )
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ColoredBox(
                  color: Color(0x22000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => const ColoredBox(
                  color: Color(0x22000000),
                  child: Icon(Icons.broken_image_outlined, size: 42),
                ),
              ),
      ),
    );
  }
}

class _CharacterAppearanceTile extends StatelessWidget {
  const _CharacterAppearanceTile({required this.appearance});

  final Map<String, dynamic> appearance;

  @override
  Widget build(BuildContext context) {
    final title = appearance['title']?.toString() ?? 'Untitled';
    final role = appearance['role']?.toString() ?? 'appearance';
    final series = appearance['series_title']?.toString();
    final volume = appearance['volume_name']?.toString();
    final itemNumber = appearance['item_number']?.toString();
    final coverUrl = appearance['cover_image_url']?.toString();
    final subtitle = [
      if (series != null && series.trim().isNotEmpty) series,
      if (volume != null && volume.trim().isNotEmpty) volume,
      if (itemNumber != null && itemNumber.trim().isNotEmpty) '#$itemNumber',
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 42,
            height: 56,
            child: coverUrl == null || coverUrl.trim().isEmpty
                ? const ColoredBox(
                    color: Color(0x22000000),
                    child: Icon(Icons.image_not_supported_outlined, size: 18),
                  )
                : CachedNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ColoredBox(
                      color: Color(0x22000000),
                    ),
                    errorWidget: (_, __, ___) => const ColoredBox(
                      color: Color(0x22000000),
                      child: Icon(Icons.broken_image_outlined, size: 18),
                    ),
                  ),
          ),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle.isEmpty ? role : '$role · $subtitle',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _MetaStatChip extends StatelessWidget {
  const _MetaStatChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

class _AliasChip extends StatelessWidget {
  const _AliasChip({required this.alias});

  final String alias;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(alias));
  }
}

class _CharacterDetailError extends StatelessWidget {
  const _CharacterDetailError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> _pickBestCharacter(
  List<Map<String, dynamic>> results,
  String query,
) {
  final normalizedQuery = _normalizeCharacterText(query);
  for (final result in results) {
    final name = _normalizeCharacterText(result['name']?.toString() ?? '');
    if (name == normalizedQuery) {
      return result;
    }
    final aliases = (result['aliases'] as List<dynamic>? ?? const []);
    if (aliases.any(
      (alias) => _normalizeCharacterText(alias.toString()) == normalizedQuery,
    )) {
      return result;
    }
  }
  return results.first;
}

String _normalizeCharacterText(String value) {
  return value.trim().toLowerCase();
}