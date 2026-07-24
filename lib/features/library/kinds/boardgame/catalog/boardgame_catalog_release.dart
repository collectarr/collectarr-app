class BoardGameRelease {
  const BoardGameRelease({
    required this.id,
    required this.title,
    this.editionTitle,
    this.publisher,
    this.catalogNumber,
    this.barcode,
    this.releaseDate,
    this.language,
    this.minPlayers,
    this.maxPlayers,
    this.playingTimeMinutes,
    this.minAge,
    this.coverImageUrl,
  });

  final String id;
  final String title;
  final String? editionTitle;
  final String? publisher;
  final String? catalogNumber;
  final String? barcode;
  final DateTime? releaseDate;
  final String? language;
  final int? minPlayers;
  final int? maxPlayers;
  final int? playingTimeMinutes;
  final int? minAge;
  final String? coverImageUrl;
}
