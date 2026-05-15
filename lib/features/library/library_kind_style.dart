import 'package:flutter/material.dart';

const Color kLibraryFallbackAccent = Color(0xFF10A8D8);

Color libraryAccentForKind(String kind) {
  return switch (kind) {
    'comic' => const Color(0xFF4DBBD5),
    'manga' => const Color(0xFFE96BA8),
    'anime' => const Color(0xFF00AFA5),
    'book' => const Color(0xFF48A868),
    'game' => const Color(0xFF7C68D8),
    'boardgame' => const Color(0xFFE0A52B),
    'movie' => const Color(0xFFE05252),
    'tv' => const Color(0xFF4E7FE5),
    'music' => const Color(0xFFE07A2D),
    _ => kLibraryFallbackAccent,
  };
}

IconData libraryIconForKind(String kind) {
  return switch (kind) {
    'anime' => Icons.animation,
    'book' => Icons.menu_book_outlined,
    'boardgame' => Icons.casino_outlined,
    'comic' => Icons.menu_book,
    'game' => Icons.sports_esports,
    'manga' => Icons.auto_stories,
    'movie' => Icons.movie_outlined,
    'music' => Icons.album_outlined,
    'tv' => Icons.tv,
    _ => Icons.category_outlined,
  };
}

String librarySidebarTitleForKind(String kind) {
  return switch (kind) {
    'anime' || 'movie' || 'tv' => 'Years',
    'music' => 'Artists',
    'book' || 'game' || 'boardgame' || 'manga' => 'Publishers',
    _ => 'Titles',
  };
}
