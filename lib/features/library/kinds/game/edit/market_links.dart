import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// PriceCharting page of a product ID, which already names the regional
/// release (NTSC or PAL). Its terms allow linking to the prices, not reading
/// them into the app, so values are only ever opened in the browser.
Uri? gamePriceChartingUri(String? priceChartingId) {
  final id = priceChartingId?.trim() ?? '';
  if (!RegExp(r'^\d+$').hasMatch(id)) return null;
  return Uri.https('www.pricecharting.com', '/game/$id');
}

/// Underlined link text of the reference Value tab and details pane.
final class GameMarketLink extends StatelessWidget {
  const GameMarketLink(
      {super.key,
      required this.label,
      required this.onTap,
      this.fontSize = 15});

  final String label;
  final VoidCallback onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Text(label,
              style: TextStyle(
                  fontSize: fontSize,
                  color: appPalette(context).link,
                  decoration: TextDecoration.underline)),
        ),
      );
}

/// "Find sold listings on eBay" for [query], while eBay links are enabled.
final class GameEbaySoldLink extends ConsumerWidget {
  const GameEbaySoldLink(
      {super.key,
      required this.query,
      this.isWishlisted = false,
      this.fontSize = 15});

  final String query;
  final bool isWishlisted;
  final double fontSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(uiPreferencesProvider);
    if (query.trim().isEmpty || !preferences.allowsEbayLinks(isWishlisted)) {
      return const SizedBox.shrink();
    }
    return GameMarketLink(
      label: 'Find sold listings on eBay',
      fontSize: fontSize,
      onTap: () => launchEbaySearch(query, isWishlisted: isWishlisted),
    );
  }
}

/// [label] opening the PriceCharting page of [priceChartingId]; plain text
/// when there is no ID to open.
final class GamePriceChartingLink extends StatelessWidget {
  const GamePriceChartingLink(
      {super.key,
      required this.label,
      required this.priceChartingId,
      this.fontSize = 15,
      this.plainStyle});

  final String label;
  final String? priceChartingId;
  final double fontSize;
  final TextStyle? plainStyle;

  @override
  Widget build(BuildContext context) {
    final uri = gamePriceChartingUri(priceChartingId);
    if (uri == null) {
      return plainStyle == null
          ? const SizedBox.shrink()
          : Text(label, style: plainStyle);
    }
    return GameMarketLink(
      label: label,
      fontSize: fontSize,
      onTap: () async {
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {
          // Platform cannot handle URL; ignore gracefully.
        }
      },
    );
  }
}
