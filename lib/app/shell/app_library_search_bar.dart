import 'package:collectarr_app/features/library/generic/mobile_search_controller.dart';
import 'package:collectarr_app/ui/app_chrome.dart';
import 'package:collectarr_app/ui/adaptive/native_system_chrome.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Search replaces the native library header without adding a toolbar row.
class AppLibrarySearchBar extends StatelessWidget {
  const AppLibrarySearchBar(
      {super.key,
      required this.controller,
      required this.kind,
      required this.pluralLabel,
      required this.accent,
      required this.animationsEnabled,
      this.searchBackground});
  final MobileLibrarySearchController controller;
  final String kind;
  final String pluralLabel;
  final Color accent;
  final bool animationsEnabled;
  final Color? searchBackground;

  @override
  Widget build(BuildContext context) {
    final toolbarIconStyle = appChromeIconButtonStyle(context);
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            FocusScope.of(context).unfocus();
            controller.close();
          }
        },
        child: AppBar(
          toolbarHeight: appShellBarHeight,
          systemOverlayStyle: nativeSystemUiStyle(
            accent: accent,
            darkAccent: searchBackground,
            palette: appPalette(context),
          ),
          backgroundColor: libraryAccentChromeFallbackColor(accent),
          foregroundColor: Colors.white,
          flexibleSpace: LibraryAccentChrome(
              accent: accent,
              animationDuration:
                  animationsEnabled ? kAppAnimNormal : Duration.zero),
          surfaceTintColor: Colors.transparent,
          leadingWidth: 80,
          leading: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                  width: 56,
                  child: BackButton(
                      style: toolbarIconStyle,
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        controller.close();
                      }))),
          titleSpacing: 0,
          title: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller.textController,
                  builder: (context, value, _) => TextField(
                        key: ValueKey('library-header-search-$kind'),
                        controller: controller.textController,
                        focusNode: controller.focusNode,
                        autofocus: true,
                        cursorColor: appPalette(context).utilityAction,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        textInputAction: TextInputAction.search,
                        onChanged: controller.change,
                        onSubmitted: (value) {
                          controller.submit(value);
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                            hintText: 'Search ${pluralLabel.toLowerCase()}...',
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: searchBackground ??
                                Colors.black.withValues(alpha: .16),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: appPalette(context).utilityAction,
                                    width: 1.5)),
                            prefixIconConstraints: const BoxConstraints(
                                minWidth: 56, minHeight: 40),
                            prefixIcon: IconButton(
                                tooltip: 'Scan barcode',
                                style: toolbarIconStyle,
                                onPressed: controller.scan,
                                icon: const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 24)),
                            suffixIcon: value.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    style: toolbarIconStyle,
                                    onPressed: controller.clear,
                                    icon: const Icon(Icons.close,
                                        color: Colors.white, size: 26)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8)),
                      ))),
        ));
  }
}
