import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/updater/app_update_service.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [uri] in the browser, telling the user when the OS cannot.
Future<void> openReleaseLink(BuildContext context, Uri uri) async {
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Keep Settings usable if the OS cannot launch a browser.
  }
  if (opened || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Could not open this link in your browser.'),
  ));
}

Future<void> showReleaseNotesPanel(
        BuildContext context, GitHubRelease release) =>
    showAppDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ReleaseNotesPanel(release: release),
    );

/// A release's notes as GitHub formats them: headings, lists, links and
/// images. Links open in the browser.
class ReleaseNotesPanel extends StatelessWidget {
  const ReleaseNotesPanel({super.key, required this.release});

  final GitHubRelease release;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final date = AppFormats.current.formatDate(release.publishedAt);
    return Dialog(
      backgroundColor: palette.panelRaised,
      surfaceTintColor: Colors.transparent,
      alignment: Alignment.topCenter,
      insetPadding: kAppDialogInsets,
      shape: appDialogShape,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 820),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AccentDialogHeader(
              title: '${release.name} - $date', icon: Icons.article_outlined),
          Expanded(
            child: Markdown(
              data: release.body,
              selectable: true,
              padding: const EdgeInsets.all(16),
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                      a: TextStyle(
                          color: palette.link,
                          decoration: TextDecoration.underline,
                          decorationColor: palette.link)),
              onTapLink: (_, href, __) {
                final uri = href == null ? null : Uri.tryParse(href);
                if (uri != null && _isWeb(uri)) openReleaseLink(context, uri);
              },
              imageBuilder: (uri, _, alt) => _isWeb(uri)
                  ? Image.network(uri.toString(),
                      errorBuilder: (_, __, ___) => Text(alt ?? ''))
                  : Text(alt ?? ''),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Notes come from the network, so they may not reach local files or apps.
bool _isWeb(Uri uri) => uri.isScheme('https') || uri.isScheme('http');
