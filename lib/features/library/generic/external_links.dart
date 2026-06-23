import 'package:url_launcher/url_launcher.dart';

Uri? buildEbaySearchUri({
  required String query,
  String categoryPath = '/sch/i.html',
  bool soldOnly = false,
}) {
  final normalizedQuery = query.trim();
  if (normalizedQuery.isEmpty) {
    return null;
  }
  return Uri.https(
    'www.ebay.com',
    categoryPath,
    <String, String>{
      '_nkw': normalizedQuery,
      if (soldOnly) 'LH_Sold': '1',
    },
  );
}

Future<void> launchEbaySearch(String query) async {
  final url = buildEbaySearchUri(query: query);
  if (url == null) {
    return;
  }
  try {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Platform cannot handle URL; ignore gracefully.
  }
}
