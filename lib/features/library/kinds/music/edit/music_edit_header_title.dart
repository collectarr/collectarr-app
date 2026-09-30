String musicEditHeaderTitle({required String title, String? artist}) {
  final albumTitle = title.trim();
  final albumArtist = artist?.trim();
  if (albumArtist == null || albumArtist.isEmpty) return albumTitle;
  return '$albumTitle / $albumArtist';
}
