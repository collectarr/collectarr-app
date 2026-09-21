/// Explicit semantic role of a provider search hit.
///
/// Entity ownership and provider search role are deliberately separate. A
/// comic issue can be a Work candidate while a variant is a Release
/// candidate, and a TV season is neither a Library Work nor a Library Copy.
enum ProviderSearchRole {
  work,
  release,
  releaseGroup,
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
        ProviderSearchRole.work => 'work',
        ProviderSearchRole.release => 'release',
        ProviderSearchRole.releaseGroup => 'release_group',
        ProviderSearchRole.series => 'series',
        ProviderSearchRole.season => 'season',
        ProviderSearchRole.episode => 'episode',
        ProviderSearchRole.issue => 'issue',
        ProviderSearchRole.variant => 'variant',
        ProviderSearchRole.volume => 'volume',
        ProviderSearchRole.edition => 'edition',
      };

  bool get isWorkLike => switch (this) {
        ProviderSearchRole.work ||
        ProviderSearchRole.releaseGroup ||
        ProviderSearchRole.series ||
        ProviderSearchRole.issue ||
        ProviderSearchRole.volume =>
          true,
        _ => false,
      };

  bool get isReleaseLike => switch (this) {
        ProviderSearchRole.release ||
        ProviderSearchRole.variant ||
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
