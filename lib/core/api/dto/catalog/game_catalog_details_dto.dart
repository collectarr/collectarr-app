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
      platforms.isNotEmpty ||
      (toySubtype != null && toySubtype!.isNotEmpty) ||
      (toyType != null && toyType!.isNotEmpty);

  Map<String, dynamic> toJson() => {
        if (platforms.isNotEmpty) 'platforms': platforms,
        if (toySubtype != null) 'toy_subtype': toySubtype,
        if (toyType != null) 'toy_type': toyType,
      };
}
