import 'package:flutter/material.dart';

enum ProviderId {
  aniList('anilist', 'AniList', icon: Icons.auto_awesome_outlined),
  bgg('bgg', 'BoardGameGeek', icon: Icons.casino_outlined),
  comicVine('comicvine', 'Comic Vine', icon: Icons.auto_stories_outlined),
  gcd('gcd', 'GCD', icon: Icons.menu_book_outlined),
  hardcover('hardcover', 'Hardcover', icon: Icons.book_outlined),
  igdb('igdb', 'IGDB', icon: Icons.sports_esports_outlined),
  mangaDex('mangadex', 'MangaDex', icon: Icons.import_contacts_outlined),
  musicBrainz('musicbrainz', 'MusicBrainz', icon: Icons.music_note_outlined),
  openLibrary('openlibrary', 'OpenLibrary', icon: Icons.local_library_outlined),
  tmdb('tmdb', 'TMDb', icon: Icons.movie_outlined),
  trakt('trakt', 'Trakt', icon: Icons.live_tv_outlined),
  simkl('simkl', 'SIMKL', icon: Icons.connected_tv_outlined),
  myAnimeList('myanimelist', 'MyAnimeList', icon: Icons.tv_outlined),
  kitsu('kitsu', 'Kitsu', icon: Icons.video_library_outlined),
  imdb('imdb', 'IMDb', icon: Icons.theaters_outlined),
  goodReads('goodreads', 'Goodreads', icon: Icons.menu_book_outlined),
  howLongToBeat('howlongtobeat', 'HowLongToBeat', icon: Icons.timer_outlined),
  steam('steam', 'Steam', icon: Icons.games_outlined);

  const ProviderId(
    this.value,
    this.label, {
    this.icon = Icons.extension_outlined,
  });

  final String value;
  final String label;
  final IconData icon;

  String get storageValue => value;

  static ProviderId? fromValue(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final id in ProviderId.values) {
      if (id.value == normalized) return id;
    }
    return switch (normalized) {
      'goodreads' || 'good_reads' => ProviderId.goodReads,
      'howlongtobeat' || 'hltb' => ProviderId.howLongToBeat,
      'myanimelist' || 'mal' => ProviderId.myAnimeList,
      'mangadex' => ProviderId.mangaDex,
      'comicvine' => ProviderId.comicVine,
      'musicbrainz' => ProviderId.musicBrainz,
      'openlibrary' => ProviderId.openLibrary,
      _ => null,
    };
  }

  static ProviderId? fromStorageValue(String? value) => fromValue(value);
}
