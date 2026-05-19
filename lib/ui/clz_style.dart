import 'package:flutter/material.dart';

const Color kClzTopBar = Color(0xFF4DBBD5);
const Color kClzToolbar = Color(0xFF2B2B2B);
const Color kClzPanel = Color(0xFF1D1D1D);
const Color kClzPanelRaised = Color(0xFF2F2F2F);
const Color kClzCanvas = Color(0xFF141414);
const Color kClzGridCanvas = Color(0xFF202020);
const Color kClzAccent = Color(0xFF10A8D8);
const Color kClzSelection = Color(0xFF075F75);
const Color kClzYellow = Color(0xFFFFD400);
const Color kClzDivider = Color(0xFF4A4A4A);
const Color kClzTextMuted = Color(0xFFB8B8B8);
const Color kClzTableOddRow = Color(0xFF202428);
const Color kClzTableEvenRow = Color(0xFF181B1E);
const Color kClzTableBottomBorder = Color(0xFF2E2E2E);
const Color kClzTableHover = Color(0xFF263940);

final ThemeData kClzComicsTheme = buildClzComicsTheme();
final ThemeData kClzAddComicDialogTheme = kClzComicsTheme.copyWith(
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF111111),
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: kClzDivider),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: kClzDivider),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: kClzAccent),
    ),
  ),
);

ThemeData buildClzComicsTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: kClzAccent,
    brightness: Brightness.dark,
    surface: kClzPanel,
  );
  return base.copyWith(
    colorScheme: scheme.copyWith(
      primary: kClzAccent,
      secondary: kClzYellow,
      surface: kClzPanel,
      surfaceContainerLowest: kClzCanvas,
      surfaceContainerLow: kClzPanel,
      surfaceContainer: kClzToolbar,
      surfaceContainerHigh: kClzPanelRaised,
      surfaceContainerHighest: const Color(0xFF3A3A3A),
      outline: kClzDivider,
      outlineVariant: const Color(0xFF373737),
    ),
    scaffoldBackgroundColor: kClzCanvas,
    dividerTheme: const DividerThemeData(
      color: kClzDivider,
      thickness: 1,
      space: 1,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF343434),
        disabledForegroundColor: const Color(0xFF777777),
        disabledBackgroundColor: const Color(0xFF252525),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kClzAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        visualDensity: VisualDensity.compact,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: kClzDivider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        visualDensity: VisualDensity.compact,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF101010),
      isDense: true,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: kClzDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kClzDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kClzAccent),
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: const WidgetStatePropertyAll(Color(0xFF101010)),
      hintStyle: const WidgetStatePropertyAll(
        TextStyle(color: kClzTextMuted),
      ),
      elevation: const WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          side: const BorderSide(color: kClzDivider),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 10),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: const Color(0xFF343434),
      selectedColor: kClzSelection,
      labelStyle: const TextStyle(color: Colors.white),
      side: const BorderSide(color: kClzDivider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: kClzPanel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: kClzDivider),
      ),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: kClzPanelRaised,
      surfaceTintColor: Colors.transparent,
      textStyle: TextStyle(color: Colors.white),
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      textStyle: TextStyle(color: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF101010),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: kClzDivider),
        ),
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}
