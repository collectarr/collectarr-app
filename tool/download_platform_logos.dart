// Downloads public-domain platform logos from Wikimedia Commons into a
// folder of your choice with an index.csv naming their platforms; select them
// all in Settings > Customization > Games > Platform icons > Load icons from
// files.
//
//   dart run tool/download_platform_logos.dart <output folder>
//
// Collectarr does not ship these logos. Each file is checked against its
// Commons licence before it is saved and skipped unless Commons marks it
// public domain. The marks remain their owners' trademarks; use them only to
// identify a platform. Microsoft's Windows and Xbox logos are not listed:
// Microsoft requires a licence for its logos. The script never touches a
// Collectarr database.
import 'dart:convert';
import 'dart:io';

/// Platform, as Collectarr names it, and its Commons file.
const _logos = [
  ('Nintendo Switch', 'Nintendo Switch Logo.svg'),
  ('Nintendo Switch 2', 'Nintendo Switch 2 logo.svg'),
  ('Wii U', 'WiiU.svg'),
  ('Wii', 'Wii.svg'),
  ('Nintendo 3DS', 'Nintendo 3DS logo.svg'),
  ('Nintendo DS', 'Nintendo DS Logo.svg'),
  ('GameCube', 'Nintendo GameCube Official Logo.svg'),
  ('NES', 'NES logo.svg'),
  ('SNES', 'SNES logo.svg'),
  ('Game Boy', 'Nintendo Game Boy Logo.svg'),
  ('Game Boy Advance', 'Game Boy Advance logo.svg'),
  ('Dreamcast', 'Dreamcast logo.svg'),
  ('Saturn', 'Sega Saturn Black Logo.svg'),
  ('Genesis / Mega Drive', 'Sega genesis logo.svg'),
];

const _userAgent = 'Collectarr platform logo downloader '
    '(https://github.com/collectarr/collectarr-app)';

Future<void> main(List<String> args) async {
  if (args.length != 1) {
    stderr.writeln(
        'Usage: dart run tool/download_platform_logos.dart <output folder>');
    exitCode = 64;
    return;
  }
  final output = Directory(args.single)..createSync(recursive: true);
  final client = HttpClient()..userAgent = _userAgent;
  final index = StringBuffer('Name,File\n');
  var saved = 0;
  try {
    for (final (platform, file) in _logos) {
      try {
        final info = await _fileInfo(client, file);
        if (info == null) {
          stdout.writeln('Skipped $platform: $file not found on Commons.');
          continue;
        }
        if (!info.licence.toLowerCase().contains('public domain')) {
          stdout.writeln('Skipped $platform: $file is "${info.licence}".');
          continue;
        }
        final bytes = await _download(client, info.url);
        // A platform's name can hold a slash, which a file name cannot.
        final fileName = '${platform.replaceAll(' / ', ' - ')}.svg';
        index.writeln('$platform,$fileName');
        File('${output.path}${Platform.pathSeparator}$fileName')
            .writeAsBytesSync(bytes);
        saved++;
        stdout.writeln('Saved $platform.svg (${info.licence}) from '
            'https://commons.wikimedia.org/wiki/File:${file.replaceAll(' ', '_')}');
      } on IOException catch (error) {
        stdout.writeln('Skipped $platform: $error');
      }
    }
  } finally {
    client.close();
  }
  File('${output.path}${Platform.pathSeparator}index.csv')
      .writeAsStringSync(index.toString());
  stdout.writeln('$saved of ${_logos.length} logos saved to ${output.path}.');
}

Future<({String url, String licence})?> _fileInfo(
    HttpClient client, String file) async {
  final uri = Uri.https('commons.wikimedia.org', '/w/api.php', {
    'action': 'query',
    'format': 'json',
    'formatversion': '2',
    'prop': 'imageinfo',
    'iiprop': 'url|extmetadata',
    'titles': 'File:$file',
  });
  final json = jsonDecode(utf8.decode(await _download(client, uri.toString())))
      as Map<String, dynamic>;
  final pages = (json['query'] as Map<String, dynamic>?)?['pages'] as List?;
  final page = pages?.firstOrNull as Map<String, dynamic>?;
  final info =
      (page?['imageinfo'] as List?)?.firstOrNull as Map<String, dynamic>?;
  if (info == null) return null;
  final metadata = info['extmetadata'] as Map<String, dynamic>? ?? const {};
  final licence = (metadata['LicenseShortName']
          as Map<String, dynamic>?)?['value'] as String? ??
      'unknown licence';
  return (url: info['url'] as String, licence: licence);
}

/// Fetches [url], pausing between requests and backing off when Wikimedia
/// asks to slow down (HTTP 429), as its robot policy requires.
Future<List<int>> _download(HttpClient client, String url) async {
  for (var attempt = 0;; attempt++) {
    await Future<void>.delayed(const Duration(seconds: 1));
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode == HttpStatus.tooManyRequests && attempt < 4) {
      await response.drain<void>();
      await Future<void>.delayed(Duration(seconds: 5 << attempt));
      continue;
    }
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      throw HttpException('HTTP ${response.statusCode} for $url');
    }
    final bytes = <int>[];
    await for (final chunk in response) {
      bytes.addAll(chunk);
    }
    return bytes;
  }
}
