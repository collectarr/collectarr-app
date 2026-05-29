import 'package:url_launcher/url_launcher.dart';

Future<void> launchEbaySearch(String query) async {
  final normalizedQuery = query.trim();
  if (normalizedQuery.isEmpty) {
    return;
  }

  final encodedQuery = Uri.encodeComponent(normalizedQuery);
  final url = Uri.parse('https://www.ebay.com/sch/i.html?_nkw=$encodedQuery');
  try {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Platform cannot handle URL; ignore gracefully.
  }
}
