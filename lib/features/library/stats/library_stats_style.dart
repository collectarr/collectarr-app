import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryStatsColors {
	const LibraryStatsColors({
		required this.toolbar,
		required this.panel,
		required this.canvas,
		required this.accent,
		required this.divider,
		required this.textMuted,
		required this.textPrimary,
		required this.panelBorder,
		required this.meterBackground,
		required this.pillBackground,
		required this.pillBorder,
	});

	final Color toolbar;
	final Color panel;
	final Color canvas;
	final Color accent;
	final Color divider;
	final Color textMuted;
	final Color textPrimary;
	final Color panelBorder;
	final Color meterBackground;
	final Color pillBackground;
	final Color pillBorder;
}

LibraryStatsColors libraryStatsColors(BuildContext context) {
	final palette = appPalette(context);
	return LibraryStatsColors(
		toolbar: palette.surface,
		panel: palette.surfaceSubtle,
		canvas: palette.surface,
		accent: kAppAccent,
		divider: palette.divider,
		textMuted: palette.textMuted,
		textPrimary: palette.textPrimary,
		panelBorder: palette.cardBorder,
		meterBackground: palette.field,
		pillBackground: Color.alphaBlend(
			kAppAccent.withValues(alpha: 0.12),
			palette.surfaceSubtle.withValues(alpha: 0.96),
		),
		pillBorder: kAppAccent.withValues(alpha: 0.42),
	);
}

const double kLibraryStatsCardWidth = 260;
const double kLibraryStatsDialogWideBreakpoint = 760;
