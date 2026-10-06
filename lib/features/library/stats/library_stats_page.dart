import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:collectarr_app/features/library/stats/library_stats_style.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Full-page statistics view matching the CLZ Web statistics layout.
class LibraryStatsPage extends StatelessWidget {
  const LibraryStatsPage({
    super.key,
    required this.type,
    required this.state,
  });

  final LibraryKindRegistration type;
  final ShelfState state;

  LibraryMediaStatsLabels get _statsLabels =>
      libraryPresentationForKind(type.kind).statsLabels;

  @override
  Widget build(BuildContext context) {
    final capability = libraryStatsForKind(type.kind);
    final customPage = capability.buildCustomStatsPage(context, state, type);
    if (customPage != null) {
      return customPage;
    }

    final accent = libraryAccentForKind(type.kind);
    final colors = libraryStatsColors(context);
    final palette = appPalette(context);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        leading: IconButton(
          key: const Key('stats.back'),
          tooltip: 'Back',
          style: IconButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
          ),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Statistics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: libraryAccentChromeFallbackColor(accent),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: LibraryAccentChrome(
          accent: accent,
          animationDuration: Duration.zero,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Top General Stats box
                    capability.buildCustomHeader(context, state, type) ??
                        _buildDefaultHeader(context, colors, palette),
                    const SizedBox(height: 16),

                    // 2. Summary tiles
                    _buildSummaryTiles(context),
                    const SizedBox(height: 20),

                    // 3. Grid of sections (2 columns wide, 1 column narrow)
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _buildLeftCards(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _buildRightCards(context),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ..._buildLeftCards(context),
                          ..._buildRightCards(context),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultHeader(
    BuildContext context,
    LibraryStatsColors colors,
    AppThemePalette palette,
  ) {
    final primaryGroupLabel = _seriesLabel;
    final primaryGroupsCount = _topSeriesCounts(state.entries, type).length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 19,
                color: palette.textPrimary,
              ),
              children: [
                TextSpan(
                  text: '${state.entries.length} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '${type.identity.pluralLabel.toLowerCase()} and '),
                TextSpan(
                  text: '$primaryGroupsCount ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: primaryGroupLabel),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${state.entryCount} collection entries',
            style: TextStyle(
              fontSize: 14,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTiles(BuildContext context) {
    final registration = type;
    final totalValue = state.totalPaidCents == null
        ? '-'
        : formatMoney(state.totalPaidCents!, state.primaryCurrency);
    final collectionValueSummary =
        libraryValueForKind(type.kind)?.resolveCollectionValueSummary(
      state.entries,
    );
    final collectionValue = collectionValueSummary == null
        ? null
        : collectionValueSummary.hasMixedCurrencies
            ? '${collectionValueSummary.valuedCount} valued'
            : collectionValueSummary.totalValueCents == null ||
                    collectionValueSummary.totalValueCents == 0
                ? null
                : formatMoney(
                    collectionValueSummary.totalValueCents!,
                    collectionValueSummary.currency,
                  );
    final sellValue = state.totalSellCents == null || state.totalSellCents == 0
        ? null
        : formatMoney(state.totalSellCents!, state.primaryCurrency);
    final kindSummaryTiles =
        libraryStatsForKind(registration.kind).buildSummaryTiles(state, type);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        LibraryStatsTile(
          icon: type.identity.icon,
          label: 'Total',
          value: state.entries.length.toString(),
        ),
        LibraryStatsTile(
          icon: Icons.check_box,
          label: 'In collection',
          value: state.entryCount.toString(),
        ),
        for (final tile in kindSummaryTiles)
          LibraryStatsTile(
            icon: tile.icon,
            label: tile.label,
            value: tile.value,
          ),
        if (state.wishlistCount > 0)
          LibraryStatsTile(
            icon: Icons.star,
            label: 'Wishlist',
            value: state.wishlistCount.toString(),
          ),
        if (state.totalPaidCents != null && state.totalPaidCents! > 0)
          LibraryStatsTile(
            icon: Icons.attach_money,
            label: 'Total paid',
            value: state.hasMixedCurrencies ? '$totalValue +' : totalValue,
          ),
        if (collectionValue != null)
          LibraryStatsTile(
            icon: Icons.inventory_2_outlined,
            label: 'Collection value',
            value: collectionValue,
          ),
        if (sellValue != null)
          LibraryStatsTile(
            icon: Icons.sell_outlined,
            label: 'Sold total',
            value: sellValue,
          ),
      ],
    );
  }

  List<Widget> _buildLeftCards(BuildContext context) {
    final formatCounts = _formatCounts(state.entries, type);
    final trackingCounts = _trackingStatusCounts(state.entries);
    final missingCovers = state.entries
        .where((e) =>
            libraryStatsForKind(type.kind)
                .buildMetadataProjection(e)
                ?.hasCover !=
            true)
        .length;
    final missingMetadata = _missingMetadataCount(state.entries, type);
    final valueCoverage =
        state.entryCount == 0 ? 0.0 : state.pricedCount / state.entryCount;

    return [
      // 1. By Format
      _cardWrapper(
        LibraryStatsDistributionCard(
          title: '${type.identity.pluralLabel} by Format',
          values: formatCounts,
        ),
      ),
      // 2. Played / Tracking Status
      _cardWrapper(
        LibraryStatsDistributionCard(
          title: _trackingTitle,
          values: trackingCounts,
        ),
      ),
      // 3. Investment / Money
      if (!state.hasMixedCurrencies &&
          state.primaryCurrency != null &&
          state.totalPaidCents != null &&
          state.totalPaidCents! > 0) ...[
        _cardWrapper(
          LibraryStatsMoneyRankedCard(
            title: 'Most Invested $_seriesLabel',
            values: _topInvestedSeries(state.entries, type),
            currency: state.primaryCurrency,
          ),
        ),
      ],
      // 4. Data Health
      _cardWrapper(
        LibraryStatsHealthCard(
          title: 'Data Health',
          rows: [
            LibraryStatsHealthRow(
              label: 'Value coverage',
              fraction: valueCoverage,
            ),
            LibraryStatsHealthRow(
              label: 'Metadata coverage',
              fraction: state.entries.isEmpty
                  ? 0.0
                  : (state.entries.length - missingMetadata) /
                      state.entries.length,
            ),
            LibraryStatsHealthRow(
              label: 'Cover coverage',
              fraction: state.entries.isEmpty
                  ? 0.0
                  : (state.entries.length - missingCovers) /
                      state.entries.length,
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildRightCards(BuildContext context) {
    final recentAdditions = state.entries.reversed.take(5).toList();
    final artistCounts = _topSeriesCounts(state.entries, type);
    final yearCounts = _releaseYearCounts(state.entries, type);
    final genreCounts = _genreCounts(state.entries, type);
    final customCards = libraryStatsForKind(type.kind)
        .buildCustomCards(context, state, type);

    return [
      // 1. Most recent additions (CLZ style)
      if (recentAdditions.isNotEmpty)
        _cardWrapper(
          _RecentAdditionsCard(
            title: 'Most recent additions',
            entries: recentAdditions,
            type: type,
          ),
        ),
      // 2. By Artist / Author / Primary Group
      if (artistCounts.isNotEmpty)
        _cardWrapper(
          LibraryStatsRankedCard(
            title: '${type.identity.pluralLabel} by $_seriesLabel',
            values: artistCounts,
          ),
        ),
      // 3. By Release Year
      if (yearCounts.isNotEmpty)
        _cardWrapper(
          LibraryStatsDistributionCard(
            title: '${type.identity.pluralLabel} by Release Year',
            values: yearCounts,
          ),
        ),
      // 4. By Genre
      if (genreCounts.isNotEmpty)
        _cardWrapper(
          LibraryStatsRankedCard(
            title: '${type.identity.pluralLabel} by Genre',
            values: genreCounts,
          ),
        ),
      // 5. Kind custom cards
      for (final card in customCards)
        _cardWrapper(card),
    ];
  }

  Widget _cardWrapper(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: child,
    );
  }

  String get _seriesLabel =>
      _statsLabels.labelFor('top_series', fallback: 'Artist');

  String get _trackingTitle {
    return switch (type.kind) {
      CatalogMediaKind.music => 'Played',
      CatalogMediaKind.movie || CatalogMediaKind.tv || CatalogMediaKind.anime => 'Watched',
      CatalogMediaKind.book || CatalogMediaKind.comic || CatalogMediaKind.manga => 'Read',
      CatalogMediaKind.game || CatalogMediaKind.boardgame => 'Played',
      _ => 'Tracking',
    };
  }

  static Map<String, int> _formatCounts(
    List<LibraryWorkspaceContext> entries,
    LibraryKindRegistration registration,
  ) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final p = libraryStatsForKind(registration.kind).buildMetadataProjection(entry);
      final format = p?.format?.trim();
      final label = (format != null && format.isNotEmpty) ? format : 'Unspecified';
      counts[label] = (counts[label] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, int> _trackingStatusCounts(
    List<LibraryWorkspaceContext> entries,
  ) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final status = entry.trackingStatus;
      final label = status == MediaTrackingStatus.none
          ? 'Not tracked'
          : status.label;
      counts[label] = (counts[label] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, int> _topSeriesCounts(
    List<LibraryWorkspaceContext> entries,
    LibraryKindRegistration registration,
  ) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final name = libraryStatsForKind(registration.kind)
          .buildMetadataProjection(entry)
          ?.primaryGroup?.trim();
      if (name == null || name.isEmpty || name == 'Unknown') continue;
      counts[name] = (counts[name] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, int> _releaseYearCounts(
    List<LibraryWorkspaceContext> entries,
    LibraryKindRegistration registration,
  ) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final p = libraryStatsForKind(registration.kind).buildMetadataProjection(entry);
      final year = p?.releaseYear;
      if (year == null) continue;
      final key = year.toString();
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, int> _genreCounts(
    List<LibraryWorkspaceContext> entries,
    LibraryKindRegistration registration,
  ) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final p = libraryStatsForKind(registration.kind).buildMetadataProjection(entry);
      if (p == null) continue;
      for (final g in p.genres) {
        final clean = g.trim();
        if (clean.isNotEmpty) counts[clean] = (counts[clean] ?? 0) + 1;
      }
    }
    return counts;
  }

  static Map<String, int> _topInvestedSeries(
    List<LibraryWorkspaceContext> entries,
    LibraryKindRegistration registration,
  ) {
    final amounts = <String, int>{};
    for (final entry in entries) {
      final cents = libraryStatsForKind(registration.kind)
          .buildEntryFinancialSummary(entry)
          .pricePaidCents;
      if (cents == null || cents <= 0) continue;
      final name = libraryStatsForKind(registration.kind)
          .buildMetadataProjection(entry)
          ?.primaryGroup?.trim();
      if (name == null || name.isEmpty) continue;
      amounts[name] = (amounts[name] ?? 0) + cents;
    }
    return amounts;
  }

  static int _missingMetadataCount(
    List<LibraryWorkspaceContext> entries,
    LibraryKindRegistration registration,
  ) {
    return entries.where((e) {
      final p = libraryStatsForKind(registration.kind).buildMetadataProjection(e);
      if (p == null) return true;
      return !p.hasSecondaryMetadata && !p.hasReleaseDate;
    }).length;
  }
}

class _RecentAdditionsCard extends StatelessWidget {
  const _RecentAdditionsCard({
    required this.title,
    required this.entries,
    required this.type,
  });

  final String title;
  final List<LibraryWorkspaceContext> entries;
  final LibraryKindRegistration type;

  @override
  Widget build(BuildContext context) {
    final colors = libraryStatsColors(context);
    final palette = appPalette(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border.all(color: colors.panelBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.accent,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0)
              Divider(
                height: 16,
                color: palette.divider.withValues(alpha: 0.5),
              ),
            _buildItemRow(context, entries[i], colors, palette),
          ],
        ],
      ),
    );
  }

  Widget _buildItemRow(
    BuildContext context,
    LibraryWorkspaceContext entry,
    LibraryStatsColors colors,
    AppThemePalette palette,
  ) {
    final summary = entry.catalogSummary;
    final title = summary?.primaryLabel ?? 'Untitled';
    final subtitle = summary?.subtitle;
    final coverUrl = summary?.imageUrl;
    final projection = libraryStatsForKind(type.kind).buildMetadataProjection(entry);

    // Music-specific rich info
    int? tracksCount;
    String? durationText;
    final formatText = projection?.format;
    final releaseYear = projection?.releaseYear;

    final catalogData = entry.kindPresentationData;
    if (catalogData is MusicWorkspaceData) {
      final music = catalogData.music;
      tracksCount = music.trackCount;
      var durationSec = 0;
      for (final t in music.tracks) {
        if (t.durationMs != null && t.durationMs! > 0) {
          durationSec += (t.durationMs! / 1000).round();
        }
      }
      if (durationSec > 0) {
        final m = durationSec ~/ 60;
        final s = durationSec % 60;
        durationText = '$m:${s.toString().padLeft(2, '0')}';
      }
    }

    final databoxParts = <String>[
      if (formatText != null && formatText.trim().isNotEmpty) formatText.trim(),
      if (releaseYear != null) releaseYear.toString(),
    ];
    final databox = databoxParts.join(' - ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Cover thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 60,
            height: 60,
            color: colors.panelBorder,
            child: coverUrl != null && coverUrl.trim().isNotEmpty
                ? Image.network(
                    coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      type.identity.icon,
                      color: colors.textMuted,
                      size: 26,
                    ),
                  )
                : Icon(
                    type.identity.icon,
                    color: colors.textMuted,
                    size: 26,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        // Item info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tracksCount != null && tracksCount > 0) ...[
                Row(
                  children: [
                    Icon(
                      Icons.music_note,
                      size: 13,
                      color: colors.textMuted,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$tracksCount tracks',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (durationText != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        durationText,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
              ],
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textMuted,
                  ),
                ),
              ],
              if (databox.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  databox,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
