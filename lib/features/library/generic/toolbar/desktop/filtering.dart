import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/features/library/generic/toolbar/alphabet_options.dart';
import 'package:collectarr_app/features/library/config/search_target.dart';
import 'package:collectarr_app/features/library/generic/toolbar/auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/chrome.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';

class LibraryDesktopFilteringToolbar extends StatelessWidget {
  const LibraryDesktopFilteringToolbar({
    super.key,
    required this.type,
    required this.accent,
    required this.searchController,
    required this.collectionStatusScope,
    required this.availableLetters,
    required this.onAdd,
    required this.onScan,
    required this.onRefreshMetadata,
    required this.onSearchChanged,
    this.onSearchInputChanged,
    this.onClearSearch,
    this.searchActive = false,
    this.searchSuggestions = const <LibraryToolbarSearchSuggestion>[],
    this.onSearchSuggestionSelected,
    this.onCollectionStatusScopeChanged,
    this.selectedLetter,
    this.alphabetOptions,
    this.onLetterSelected,
    this.onRandomPick,
    this.onScanCover,
    this.searchTarget = LibrarySearchTarget.all,
    this.searchTargetOptions = const <LibrarySearchTarget>[],
    this.onSearchTargetChanged,
  });

  final LibraryKindRegistration type;
  final Color accent;
  final TextEditingController searchController;
  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final Set<String> availableLetters;
  final String? selectedLetter;
  final LibraryAlphabetOptions? alphabetOptions;
  final ValueChanged<String?>? onLetterSelected;
  final VoidCallback onAdd;
  final VoidCallback onScan;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String>? onSearchInputChanged;
  final VoidCallback? onClearSearch;
  final bool searchActive;
  final List<LibraryToolbarSearchSuggestion> searchSuggestions;
  final ValueChanged<LibraryToolbarSearchSuggestion>?
      onSearchSuggestionSelected;
  final VoidCallback? onRandomPick;
  final VoidCallback? onScanCover;
  final LibrarySearchTarget searchTarget;
  final List<LibrarySearchTarget> searchTargetOptions;
  final ValueChanged<LibrarySearchTarget>? onSearchTargetChanged;

  @override
  Widget build(BuildContext context) {
    final showChromeRow = !appPresentationPlatform.isNativeMobile &&
        onCollectionStatusScopeChanged != null;
    final narrow = MediaQuery.sizeOf(context).width < 900;
    final showAlphabetRow = onLetterSelected != null && !narrow;
    final leftControls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!narrow)
          LibraryToolbarPrimaryActions(
            addLabel: 'Add ${type.identity.pluralLabel}',
            onAdd: onAdd,
            onScanBarcode: onScan,
            onRefreshMetadata: onRefreshMetadata,
            onRandomPick: onRandomPick,
            onScanCover: onScanCover,
            // Add is a utility action: shared blue in every kind, as in the
            // reference.
            addBackgroundColor: appPalette(context).utilityAction,
            addForegroundColor: Colors.white,
          ),
        if (showChromeRow) ...[
          const LibraryWorkspaceSeparator(),
          LibraryCollectionStatusScopeDropdown(
            collectionStatusScope: collectionStatusScope,
            onCollectionStatusScopeChanged: onCollectionStatusScopeChanged!,
          ),
          const LibraryWorkspaceSeparator(),
        ],
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 2, bottom: 2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sideWidth =
              (constraints.maxWidth * 0.3).clamp(0.0, 420.0).toDouble();
          final searchWidth = (constraints.maxWidth * (narrow ? 0.58 : 0.3))
              .clamp(0.0, 480.0)
              .toDouble();
          return Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: sideWidth),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: leftControls,
                ),
              ),
              const SizedBox(width: 6),
              if (showAlphabetRow)
                Expanded(
                  child: LibraryToolbarAlphabetRow(
                    letters: availableLetters,
                    selectedLetter: selectedLetter,
                    alphabetOptions: alphabetOptions,
                    accent: accent,
                    onLetterSelected: onLetterSelected!,
                  ),
                )
              else
                const Expanded(child: SizedBox.shrink()),
              const SizedBox(width: 6),
              SizedBox(
                width: searchWidth,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: LibraryToolbarSearch(
                    controller: searchController,
                    hintText: libraryPresentationForKind(type.kind)
                            .searchFieldLabels
                            .libraryHint ??
                        'Search ${type.identity.pluralLabel.toLowerCase()}...',
                    onScanBarcode: onScan,
                    onScanCover: onScanCover,
                    onRandomPick: onRandomPick,
                    onSearch: onSearchChanged,
                    onChanged: onSearchInputChanged,
                    selectionColor: appPalette(context).utilityAction,
                    searchTarget: searchTarget,
                    searchTargetOptions: searchTargetOptions,
                    onSearchTargetChanged: onSearchTargetChanged,
                    onClearSearch: onClearSearch,
                    searchActive: searchActive,
                    suggestions: searchSuggestions,
                    onSuggestionSelected: onSearchSuggestionSelected,
                    maxWidth: 400,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
