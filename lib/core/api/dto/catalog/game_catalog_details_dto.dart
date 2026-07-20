class GameCatalogDetailsDto {
  const GameCatalogDetailsDto({
    this.platforms = const <String>[],
    this.toySubtype,
    this.toyType,
  });

  final List<String> platforms;
  final String? toySubtype;
  final String? toyType;

  bool get hasData =>
      platforms.isNotEmpty || toySubtype != null || toyType != null;
}
