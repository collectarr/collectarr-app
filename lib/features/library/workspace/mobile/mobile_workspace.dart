import 'dart:math' as math;

import 'package:collectarr_app/features/library/config/entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart'
    show LibraryCollectionStatusScope;
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/ui/primitives/collection_status_field.dart'
    show libraryCollectionStatusFromValue;
import 'package:collectarr_app/features/library/ui/primitives/collection_status_icon.dart';
import 'package:collectarr_app/features/library/workspace/entry/view_state.dart';
import 'package:collectarr_app/features/library/workspace/mobile/mobile_view_mode.dart';
import 'package:collectarr_app/features/library/workspace/tiles/card_presentation.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/tiles/item_status_badge.dart';
import 'package:collectarr_app/features/library/workspace/tiles/outlined_pill.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

const _kMobileImageMinWidth = 56.0;
const _kMobileImageMaxWidth = 200.0;
const _kMobileImageGap = 2.0;
const _kMobileCardMinWidth = 125.0;
const _kMobileCardGap = 6.0;
const _kMobileListRowHeight = 72.0;
const _kMobileListCoverWidth = 47.0;

/// The phone library: List, Cards and Images, as in the reference. Selection
/// and opening are the only item gestures; the desktop workspace keeps its
/// own layouts, panes and pointer handling.
class LibraryMobileWorkspace extends StatelessWidget {
  const LibraryMobileWorkspace({
    super.key,
    required this.type,
    required this.items,
    required this.viewState,
    required this.selectionEnabled,
    required this.selectedIds,
    required this.onOpenItem,
    required this.onToggleSelectionItem,
    required this.emptyBuilder,
    required this.tabletPanes,
    required this.selectedId,
    required this.onActivateItem,
  });

  final LibraryKindRegistration type;
  final List<LibraryProjectionItem> items;
  final LibraryWorkspaceViewState viewState;
  final bool selectionEnabled;
  final Set<String> selectedIds;
  final ValueChanged<LibraryProjectionItem> onOpenItem;
  final ValueChanged<String> onToggleSelectionItem;
  final WidgetBuilder emptyBuilder;

  /// A tablet shows the tapped item in its details pane instead of opening it.
  final bool tabletPanes;
  final String? selectedId;
  final ValueChanged<String> onActivateItem;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Builder(builder: emptyBuilder);
    final profile = libraryViewProfileForKind(type.kind);
    final coverRatio = 1 / profile.coverGridHeightFactor;
    return switch (LibraryMobileViewMode.from(viewState.viewMode)) {
      LibraryMobileViewMode.list => ListView.builder(
          key: const Key('library.mobile-list'),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              _ListRow(data: _tileData(items[index])),
        ),
      LibraryMobileViewMode.cards => LayoutBuilder(
          builder: (context, constraints) {
            final columns = math.max(
                2,
                ((constraints.maxWidth - _kMobileCardGap) /
                        (_kMobileCardMinWidth + _kMobileCardGap))
                    .floor());
            final width =
                (constraints.maxWidth - _kMobileCardGap * (columns + 1)) /
                    columns;
            return GridView.builder(
              key: const Key('library.mobile-cards'),
              padding: const EdgeInsets.all(_kMobileCardGap),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: _kMobileCardGap,
                mainAxisSpacing: _kMobileCardGap,
                mainAxisExtent: _cardHeight(width, coverRatio),
              ),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  _CardTile(data: _tileData(items[index])),
            );
          },
        ),
      LibraryMobileViewMode.images => GridView.builder(
          key: const Key('library.mobile-images'),
          padding: const EdgeInsets.all(_kMobileImageGap),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: _imageWidth(profile.minCoverSize,
                profile.maxCoverSize, viewState.coverSize),
            crossAxisSpacing: _kMobileImageGap,
            mainAxisSpacing: _kMobileImageGap,
            childAspectRatio: coverRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              _ImageTile(data: _tileData(items[index])),
        ),
    };
  }

  _TileData _tileData(LibraryProjectionItem item) {
    final presentation = libraryCardPresentationForEntry(item);
    return _TileData(
      item: item,
      presentation: presentation,
      content: presentation.mobileTile ??
          LibraryMobileTileContent(
            headline: item.dto.primaryLabel,
            subtitle: item.dto.secondaryLabel,
          ),
      selected: selectedIds.contains(item.target.id),
      active: tabletPanes && item.target.id == selectedId,
      selectionMode: selectionEnabled,
      onTap: selectionEnabled
          ? () => onToggleSelectionItem(item.target.id)
          : tabletPanes
              ? () => onActivateItem(item.target.id)
              : () => onOpenItem(item),
    );
  }
}

/// The phone slider shares the stored cover size with its kind's range, drawn
/// across the narrower widths a phone's columns need.
double _imageWidth(double min, double max, double value) =>
    _kMobileImageMinWidth +
    (_kMobileImageMaxWidth - _kMobileImageMinWidth) *
        ((value - min) / (max - min)).clamp(0.0, 1.0);

/// Card frame, two title lines, the cover, then the number and detail lines.
double _cardHeight(double width, double coverRatio) =>
    2 + 42 + (width - 12) / coverRatio + 58;

class _TileData {
  const _TileData({
    required this.item,
    required this.presentation,
    required this.content,
    required this.selected,
    required this.active,
    required this.selectionMode,
    required this.onTap,
  });

  final LibraryProjectionItem item;
  final LibraryCardPresentation presentation;
  final LibraryMobileTileContent content;
  final bool selected;
  final bool active;
  final bool selectionMode;
  final VoidCallback onTap;

  Widget buildCover(BuildContext context, {required double width}) {
    final wrap = presentation.coverOverlayBuilder ?? (Widget cover) => cover;
    final ratio = MediaQuery.devicePixelRatioOf(context);
    return wrap(LibraryCoverImage(
      title: content.headline,
      mediaKind: item.source.mediaKind,
      imageUrl: item.dto.imageUrl,
      libraryEntryRef: item.source.libraryEntryRef,
      targetCacheWidth: (width * ratio * 2).round(),
      fit: BoxFit.cover,
      borderRadius: 0,
    ));
  }

  /// Covers mark only what differs from a plain owned copy; the reference
  /// draws those bare.
  bool get showsStatusOnCover {
    final source = item.source;
    if (source.loans.isNotEmpty) return true;
    final entry = source.libraryEntrySummary;
    if (entry == null) return source.isWishlisted;
    return libraryCollectionStatusFromValue(entry.collectionStatus) !=
        LibraryCollectionStatusScope.inCollection;
  }
}

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({required this.data, required this.child});
  final _TileData data;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Semantics(
      button: true,
      selected: data.selected,
      label: [data.content.headline, data.content.numberLabel]
          .whereType<String>()
          .join(' '),
      child: Material(
        color: data.selected || data.active
            ? palette.utilityAction.withValues(alpha: .35)
            : Colors.transparent,
        child: InkWell(
          onTap: data.onTap,
          child: Stack(fit: StackFit.passthrough, children: [
            child,
            if (data.active)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: palette.utilityAction, width: 3),
                    ),
                  ),
                ),
              ),
            if (data.selectionMode)
              Positioned(
                left: 5,
                bottom: 5,
                child: LibraryTileSelectionToggle(
                  selected: data.selected,
                  accentColor: palette.utilityAction,
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

class _StatusOnCover extends StatelessWidget {
  const _StatusOnCover({required this.data});
  final _TileData data;

  @override
  Widget build(BuildContext context) => Positioned(
        right: 3,
        bottom: 3,
        child: LibraryItemStatusBadge(
          item: data.item,
          selected: data.selected,
          style: LibraryCollectionStatusMarkStyle.cover,
        ),
      );
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge(this.text, {required this.fontSize});
  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final color = appPalette(context).textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          maxLines: 1, style: TextStyle(color: color, fontSize: fontSize)),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({required this.data});
  final _TileData data;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final content = data.content;
    return _SelectableTile(
      data: data,
      child: Container(
        height: _kMobileListRowHeight,
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: palette.divider))),
        child: Row(children: [
          SizedBox(
            width: _kMobileListCoverWidth,
            height: _kMobileListRowHeight,
            child: data.buildCover(context, width: _kMobileListCoverWidth),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(content.headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary)),
                  if (content.subtitle case final subtitle?)
                    Text(subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(fontSize: 13, color: palette.textMuted)),
                  if (content.pill case final pill?)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: LibraryOutlinedPill(
                          pill: pill, color: palette.utilityAction),
                    ),
                ]),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 18, 4),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (content.numberLabel case final number?)
                    _NumberBadge(number, fontSize: 15),
                  if (content.dateLabel case final date?)
                    Text(date,
                        style:
                            TextStyle(fontSize: 12, color: palette.textMuted)),
                  LibraryItemStatusBadge(
                    item: data.item,
                    selected: data.selected,
                    style: LibraryCollectionStatusMarkStyle.row,
                    width: 18,
                    height: 16,
                  ),
                ]),
          ),
        ]),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.data});
  final _TileData data;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final content = data.content;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border.all(color: palette.cardBorder),
      ),
      child: _SelectableTile(
        data: data,
        child: LayoutBuilder(
          builder: (context, constraints) => Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 38,
                child: Text(content.headline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary)),
              ),
              Expanded(
                child: Stack(fit: StackFit.expand, children: [
                  data.buildCover(context, width: constraints.maxWidth),
                  if (data.showsStatusOnCover) _StatusOnCover(data: data),
                ]),
              ),
              const SizedBox(height: 4),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (content.numberLabel case final number?)
                  Flexible(child: _NumberBadge(number, fontSize: 14)),
                const Spacer(),
                if (content.dateLabel case final date?)
                  Text(date.replaceFirst(', ', '\n'),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 11, height: 1.2, color: palette.textMuted)),
              ]),
              if (content.subtitle case final subtitle?)
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: palette.textMuted)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.data});
  final _TileData data;

  @override
  Widget build(BuildContext context) => _SelectableTile(
        data: data,
        child: LayoutBuilder(
          builder: (context, constraints) =>
              Stack(fit: StackFit.expand, children: [
            Opacity(
              opacity: data.selected ? .5 : 1,
              child: data.buildCover(context, width: constraints.maxWidth),
            ),
            if (data.showsStatusOnCover) _StatusOnCover(data: data),
          ]),
        ),
      );
}
