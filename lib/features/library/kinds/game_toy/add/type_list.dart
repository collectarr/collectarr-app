import 'dart:convert';

import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/add/contracts/capability.dart';
import 'package:collectarr_app/ui/app_icons.dart';

/// The toy lines of the reference's "Choose your toy type" page.
const _toyTypes = [
  'Amiibo',
  'Skylanders',
  'Disney Infinity',
  'LEGO Dimensions',
  'Starlink',
  'Pokémon Rumble U',
  'U.B. Funkeys',
];

/// Core returns at most this many rows a page.
const _pageSize = 100;

Map<String, Object> _typeQuery(String type) => {
      'kind': 'game_toy',
      'field_filters': jsonEncode({
        'toy_type': [type]
      }),
    };

/// Add Toys' List tab: a tile per toy line, then that line by series.
final gameToyAddTypes = LibraryAddBrowseCapability(
  label: 'List',
  hintText: '',
  icon: AppIcons.search,
  searchGroups: (api, _) => Future.wait([
    for (final type in _toyTypes) _typeGroup(api, type),
  ]),
  loadItemRows: _loadTypeRows,
  ownedGroupKey: (entry) => _toyTypeKey(entry.catalogData['toy_type']),
  tiles: LibraryAddBrowseTiles(
    prompt: 'Choose your toy type',
    sectionLabel: 'Series',
    sectionOf: (item) => item.kindCapability
        .mapTransport((transport) => transport.kindData['series_title'])
        ?.toString()
        .trim(),
  ),
);

String? _toyTypeKey(Object? type) => (type as String?)?.trim().toLowerCase();

Future<LibraryAddBrowseGroup> _typeGroup(ApiClient api, String type) async {
  final query = _typeQuery(type);
  final page = await api.getJsonObject('/api/v1/search', queryParameters: {
    ...query,
    'limit': 1,
    'include_total': true,
  });
  return LibraryAddBrowseGroup(
    title: type,
    countLabel: '${page['total'] ?? 0}',
    query: query,
    ownedKey: _toyTypeKey(type),
  );
}

Future<List<Map<String, dynamic>>> _loadTypeRows(
    ApiClient api, LibraryAddBrowseGroup group) async {
  final rows = <Map<String, dynamic>>[];
  while (true) {
    final page = await api.getJsonObject('/api/v1/search', queryParameters: {
      ...group.query,
      'limit': _pageSize,
      'offset': rows.length,
    });
    final items = (page['items'] as List).cast<Map<String, dynamic>>();
    rows.addAll(items);
    if (items.length < _pageSize) return rows;
  }
}
