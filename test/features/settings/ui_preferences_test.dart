import 'package:collectarr_app/features/settings/ebay_search_preferences.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('display preferences round-trip and restore defaults', () async {
    SharedPreferences.setMockInitialValues({});
    const store = UiPreferencesStore();
    final defaults = await store.read();
    expect(defaults.showInspectorBackdrop, isTrue);
    expect(defaults.showInspectorBackCover, isTrue);
    final edited = defaults.copyWith(
      showInspectorBackdrop: false,
      showInspectorBackCover: false,
      wrapColumnContent: false,
      autoSizeColumns: true,
      showCollectionIndicators: false,
      showEditIcons: false,
      detailsPanelTemplate: DetailsPanelTemplate.light,
      confirmRemoval: false,
      confirmDuplication: false,
      showEbayLinks: false,
      ebayWishlistOnly: true,
      ebayToolbar: false,
      ebayNextToCover: false,
      ebayLinksSection: false,
      ebayRegion: EbayRegion.gb,
      ebaySearchFilter: EbaySearchFilter.all,
    );
    await store.write(edited);
    final loaded = await store.read();
    expect(loaded.showInspectorBackdrop, isFalse);
    expect(loaded.showInspectorBackCover, isFalse);
    expect(loaded.wrapColumnContent, isFalse);
    expect(loaded.autoSizeColumns, isTrue);
    expect(loaded.showCollectionIndicators, isFalse);
    expect(loaded.showEditIcons, isFalse);
    expect(loaded.detailsPanelTemplate, DetailsPanelTemplate.light);
    expect(loaded.confirmRemoval, isFalse);
    expect(loaded.confirmDuplication, isFalse);
    expect(loaded.allowsEbayLinks(true), isFalse);
    expect(loaded.ebayToolbar, isFalse);
    expect(loaded.ebayNextToCover, isFalse);
    expect(loaded.ebayLinksSection, isFalse);
    expect(loaded.ebayRegion, EbayRegion.gb);
    expect(loaded.ebaySearchFilter, EbaySearchFilter.all);
    await store.write(const UiPreferences());
    expect((await store.read()).showInspectorBackdrop, isTrue);
    expect((await store.read()).autoSizeColumns, isFalse);
    expect((await store.read()).ebayRegion, EbayRegion.defaultRegion);
    expect((await store.read()).ebaySearchFilter, EbaySearchFilter.automatic);
  });

  test('eBay visibility follows global and wishlist settings', () {
    const prefs = UiPreferences(ebayWishlistOnly: true);
    expect(prefs.allowsEbayLinks(false), isFalse);
    expect(prefs.allowsEbayLinks(true), isTrue);
    expect(prefs.copyWith(showEbayLinks: false).allowsEbayLinks(true), isFalse);
  });
}
