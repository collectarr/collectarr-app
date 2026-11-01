import 'package:collectarr_app/features/library/workspace/config/tokens.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:flutter/material.dart';

class LibraryEmptyState extends StatelessWidget {
  const LibraryEmptyState({
    super.key,
    required this.type,
    required this.hasActiveFilter,
    required this.onClearFilter,
  });

  final LibraryKindRegistration type;
  final bool hasActiveFilter;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) => hasActiveFilter
      ? _NoResultsBanner(onReset: onClearFilter)
      : _EmptyCollectionBanner(type: type);
}

/// The reference's blue "No comics yet." banner over an empty collection,
/// pointing at the blue Add button in the toolbar.
class _EmptyCollectionBanner extends StatelessWidget {
  const _EmptyCollectionBanner({required this.type});

  final LibraryKindRegistration type;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final plural = type.identity.pluralLabel;
    return _Banner(
      color: palette.utilityAction,
      children: [
        Text('No ${plural.toLowerCase()} yet.', style: _bannerTitleStyle),
        const SizedBox(height: 15),
        Text.rich(
          TextSpan(children: [
            TextSpan(
                text: 'To start adding your ${plural.toLowerCase()}, '
                    'use the blue '),
            const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(AppIcons.add, size: 11, color: Colors.white)),
            TextSpan(
                text: ' Add $plural',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const TextSpan(text: ' button above'),
          ]),
          style: const TextStyle(
              fontSize: 14, height: 20 / 14, color: Colors.white),
        ),
      ],
    );
  }
}

const _bannerTitleStyle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: Colors.white);

/// A full-width banner at the top of the empty item list: 10 px above, 5 px
/// at the sides and 20 px inside, as in the reference.
class _Banner extends StatelessWidget {
  const _Banner({required this.color, required this.children});

  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ColoredBox(
        // The item views' background, dark as behind the reference's banner.
        color: libraryViewBackgroundColor(context),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            padding: const EdgeInsets.all(20),
            color: color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ),
      );
}

/// The reference's blue "No results found..." banner over the empty list,
/// with a white Reset all filters button.
class _NoResultsBanner extends StatelessWidget {
  const _NoResultsBanner({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final blue = palette.utilityAction;
    return _Banner(
      color: blue,
      children: [
        const Row(children: [
          Icon(Icons.search, size: 26, color: Colors.white),
          SizedBox(width: 6),
          Flexible(
            child: Text('No results found...', style: _bannerTitleStyle),
          ),
        ]),
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: onReset,
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: blue,
            minimumSize: const Size(0, 32),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            textStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          icon: const Icon(Icons.sync, size: 14),
          label: const Text('Reset all filters'),
        ),
      ],
    );
  }
}
