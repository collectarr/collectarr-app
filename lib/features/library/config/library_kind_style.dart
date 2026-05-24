import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:flutter/material.dart';

const Color kLibraryFallbackAccent = Color(0xFF10A8D8);

Color libraryAccentForKind(Object? kind) {
  return switch (catalogMediaKindFromValue(kind)) {
    CatalogMediaKind.comic => const Color(0xFF4DBBD5),
    CatalogMediaKind.manga => const Color(0xFFE96BA8),
    CatalogMediaKind.anime => const Color(0xFF00AFA5),
    CatalogMediaKind.book => const Color(0xFF48A868),
    CatalogMediaKind.game => const Color(0xFF7C68D8),
    CatalogMediaKind.boardgame => const Color(0xFFE0A52B),
    CatalogMediaKind.movie => const Color(0xFFE05252),
    CatalogMediaKind.tv => const Color(0xFF4E7FE5),
    CatalogMediaKind.music => const Color(0xFFE07A2D),
    _ => kLibraryFallbackAccent,
  };
}

LinearGradient libraryChromeGradient(
  Color accent, {
  AlignmentGeometry begin = Alignment.topLeft,
  AlignmentGeometry end = Alignment.bottomRight,
}) {
  return LinearGradient(
    begin: begin,
    end: end,
    colors: [
      Color.alphaBlend(
        Colors.black.withValues(alpha: 0.34),
        accent,
      ),
      Color.alphaBlend(
        Colors.black.withValues(alpha: 0.62),
        accent,
      ),
    ],
  );
}

IconData libraryIconForKind(Object? kind) {
  return switch (catalogMediaKindFromValue(kind)) {
    CatalogMediaKind.anime => Icons.movie_filter_outlined,
    CatalogMediaKind.book => Icons.menu_book_outlined,
    CatalogMediaKind.boardgame => Icons.casino_outlined,
    CatalogMediaKind.comic => Icons.library_books,
    CatalogMediaKind.game => Icons.sports_esports,
    CatalogMediaKind.manga => Icons.auto_stories,
    CatalogMediaKind.movie => Icons.movie_outlined,
    CatalogMediaKind.music => Icons.music_note,
    CatalogMediaKind.tv => Icons.tv,
    _ => Icons.category_outlined,
  };
}

String librarySidebarTitleForKind(Object? kind) {
  return switch (catalogMediaKindFromValue(kind)) {
    CatalogMediaKind.movie => 'Years',
    CatalogMediaKind.music => 'Artists',
    CatalogMediaKind.manga || CatalogMediaKind.anime || CatalogMediaKind.tv =>
      'Series',
    CatalogMediaKind.book ||
    CatalogMediaKind.game ||
    CatalogMediaKind.boardgame => 'Publishers',
    _ => 'Titles',
  };
}
