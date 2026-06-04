import 'package:collectarr_app/features/library/add/library_add_dialog_theme.dart';
import 'package:collectarr_app/features/library/add/library_cover_scan_service.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryQueuedProviderIngest {
  const LibraryQueuedProviderIngest({
    required this.id,
    required this.status,
  });

  final String id;
  final String status;

  String get shortId {
    final trimmed = id.trim();
    if (trimmed.length <= 8) {
      return trimmed;
    }
    return trimmed.substring(0, 8);
  }

  String get statusLabel {
    final trimmed = status.trim();
    if (trimmed.isEmpty) {
      return 'Queued';
    }
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }
}

enum LibraryAddDialogMode { search, barcode, manual }

class LibraryCoverScanPrefillBanner extends StatelessWidget {
  const LibraryCoverScanPrefillBanner({super.key, required this.result});

  final LibraryCoverScanResult result;

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      if (result.query != null && result.query!.trim().isNotEmpty)
        result.query!,
      if (result.issueNumber != null && result.issueNumber!.trim().isNotEmpty)
        '#${result.issueNumber}',
      if (result.year != null) result.year!.toString(),
      if (result.publisher != null && result.publisher!.trim().isNotEmpty)
        result.publisher!,
    ];
    final confidence = result.confidenceLabel?.trim();
    final reviewSummary = result.reviewSummary?.trim();
    final palette = appPalette(context);
    final bannerColor = Color.alphaBlend(
      kAppAccent.withValues(alpha: palette.isDark ? 0.18 : 0.1),
      palette.surfaceDim,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bannerColor,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            const Icon(Icons.photo_camera_outlined,
                size: 18, color: kAppAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                details.isEmpty
                    ? 'Cover scan filled search hints. Review them before searching Core.'
                    : 'Cover scan filled search hints: ${details.join(' | ')}${confidence == null || confidence.isEmpty ? '' : ' ($confidence confidence)'}${reviewSummary == null || reviewSummary.isEmpty ? '' : ' • $reviewSummary'}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const double kLibraryAddControlHeight = 34;
const double kLibraryAddModeControlHeight = 36;

ButtonStyle libraryAddOutlinedButtonStyle([Color accent = kAppAccent]) {
  return OutlinedButton.styleFrom(
    foregroundColor: accent,
    side: BorderSide(color: accent.withValues(alpha: 0.78)),
    minimumSize: const Size(0, kLibraryAddControlHeight),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    textStyle: const TextStyle(fontWeight: FontWeight.w800),
  );
}

ThemeData buildLibraryAddDialogTheme(Color accent, AppThemePalette palette) {
  return libraryAddDialogTheme(accent, palette: palette);
}
