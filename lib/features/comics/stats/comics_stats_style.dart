import 'package:flutter/material.dart';

const Color kComicsStatsToolbar = Color(0xFF2B2B2B);
const Color kComicsStatsPanel = Color(0xFF242424);
const Color kComicsStatsCanvas = Color(0xFF141414);
const Color kComicsStatsAccent = Color(0xFF10A8D8);
const Color kComicsStatsDivider = Color(0xFF4A4A4A);
const Color kComicsStatsTextMuted = Color(0xFFB8B8B8);
const Color kComicsStatsPanelBorder = Color(0xFF383838);
const Color kComicsStatsMeterBackground = Color(0xFF151515);

const double kComicsStatsCardWidth = 260;
const double kComicsStatsDialogWideBreakpoint = 760;

String formatComicsStatsMoney(int? cents, String? currency) {
  if (cents == null) {
    return '';
  }
  final sign = cents < 0 ? '-' : '';
  final absolute = cents.abs();
  final whole = absolute ~/ 100;
  final fraction = (absolute % 100).toString().padLeft(2, '0');
  final prefix = currency == null || currency.isEmpty ? '' : '$currency ';
  return '$prefix$sign$whole.$fraction';
}
