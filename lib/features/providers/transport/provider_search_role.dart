/// Describes the provider record returned by search.
///
/// Catalog items are selected directly. A series can be supplied as grouping
/// context, while seasons, episodes, issues, variants, volumes, and editions
/// describe kind-specific catalog shapes without creating a generic
/// Work/Release hierarchy.
enum ProviderSearchRole {
  catalogItem,
  series,
  season,
  episode,
  issue,
  variant,
  volume,
  edition,
}

extension ProviderSearchRoleApi on ProviderSearchRole {
  String get apiValue => switch (this) {
        ProviderSearchRole.catalogItem => 'catalog_item',
        ProviderSearchRole.series => 'series',
        ProviderSearchRole.season => 'season',
        ProviderSearchRole.episode => 'episode',
        ProviderSearchRole.issue => 'issue',
        ProviderSearchRole.variant => 'variant',
        ProviderSearchRole.volume => 'volume',
        ProviderSearchRole.edition => 'edition',
      };

  /// Whether the hit can directly become a top-level Catalog Item.
  bool get isCatalogItem => switch (this) {
        ProviderSearchRole.catalogItem ||
        ProviderSearchRole.season ||
        ProviderSearchRole.issue ||
        ProviderSearchRole.variant ||
        ProviderSearchRole.volume ||
        ProviderSearchRole.edition =>
          true,
        _ => false,
      };
}

ProviderSearchRole providerSearchRoleFromApiValue(Object? value) {
  final normalized = value?.toString().trim().toLowerCase();
  for (final role in ProviderSearchRole.values) {
    if (role.apiValue == normalized) return role;
  }
  throw FormatException('Unsupported provider search role: $value');
}
