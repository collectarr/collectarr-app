import 'package:collectarr_app/features/settings/ebay_search_preferences.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

Uri? buildEbaySearchUri({
  required String query,
  String categoryPath = '/sch/i.html',
  bool soldOnly = false,
  EbayRegion region = EbayRegion.defaultRegion,
}) {
  final normalizedQuery = query.trim();
  if (normalizedQuery.isEmpty) {
    return null;
  }
  return Uri.https(
    region.host,
    categoryPath,
    <String, String>{
      '_nkw': normalizedQuery,
      if (soldOnly) 'LH_Sold': '1',
    },
  );
}

Future<void> launchEbaySearch(String query, {bool isWishlisted = false}) async {
  final preferences = await const UiPreferencesStore().read();
  final url = buildEbaySearchUri(
      query: query,
      region: preferences.ebayRegion,
      soldOnly:
          preferences.ebaySearchFilter.soldOnlyFor(isWishlisted: isWishlisted));
  if (url == null) {
    return;
  }
  try {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Platform cannot handle URL; ignore gracefully.
  }
}
