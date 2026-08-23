import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/updater/app_update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Nullable copy semantics', () {
    test(
        'OwnedItem.copyWith allows preserving, updating, and clearing nullable fields',
        () {
      final item = OwnedItem(
        id: 'item-1',
        catalogRef: CatalogEntityRef(
          kind: CatalogMediaKind.comic.apiValue,
          id: 'cat-1',
          entityType: CatalogEntityType.issue,
        ),
        condition: 'Near Mint',
        grade: '9.8',
        purchaseDate: DateTime.utc(2025, 1, 1),
        pricePaidCents: 5000,
        currency: 'USD',
        personalNotes: 'Special note',
        locationId: 'loc-1',
        purchaseStore: 'Comic Shop',
        collectionStatus: 'Owned',
        marketValueCents: 10000,
        soldTo: 'Buyer 1',
        soldAt: DateTime.utc(2025, 2, 1),
        sellPriceCents: 8000,
        updatedAt: DateTime.utc(2025, 1, 1),
      );

      // 1. Omitted -> preserve
      final preserved = item.copyWith();
      expect(preserved.condition, 'Near Mint');
      expect(preserved.grade, '9.8');
      expect(preserved.locationId, 'loc-1');
      expect(preserved.marketValueCents, 10000);
      expect(preserved.soldTo, 'Buyer 1');

      // 2. Set -> replace
      final replaced = item.copyWith(
        condition: 'Very Fine',
        grade: '8.0',
        locationId: 'loc-2',
        marketValueCents: 12000,
        soldTo: 'Buyer 2',
      );
      expect(replaced.condition, 'Very Fine');
      expect(replaced.grade, '8.0');
      expect(replaced.locationId, 'loc-2');
      expect(replaced.marketValueCents, 12000);
      expect(replaced.soldTo, 'Buyer 2');

      // 3. Clear -> null
      final cleared = item.copyWith(
        condition: null,
        grade: null,
        locationId: null,
        marketValueCents: null,
        soldTo: null,
        soldAt: null,
        sellPriceCents: null,
        purchaseDate: null,
        personalNotes: null,
      );
      expect(cleared.condition, isNull);
      expect(cleared.grade, isNull);
      expect(cleared.locationId, isNull);
      expect(cleared.marketValueCents, isNull);
      expect(cleared.soldTo, isNull);
      expect(cleared.soldAt, isNull);
      expect(cleared.sellPriceCents, isNull);
      expect(cleared.purchaseDate, isNull);
      expect(cleared.personalNotes, isNull);
    });

    test(
        'ComicOwnedDetails.copyWith allows preserving, updating, and clearing fields',
        () {
      final comic = const ComicOwnedDetails(
        rawOrSlabbed: 'Slabbed',
        gradingCompany: 'CGC',
        certificationNumber: '1234567890',
        signedBy: 'Stan Lee',
      );

      // Omitted -> preserve
      expect(comic.copyWith().gradingCompany, 'CGC');
      expect(comic.copyWith().certificationNumber, '1234567890');

      // Set -> replace
      expect(comic.copyWith(gradingCompany: 'CBCS').gradingCompany, 'CBCS');

      // Clear -> null
      final cleared = comic.copyWith(
        gradingCompany: null,
        certificationNumber: null,
        signedBy: null,
      );
      expect(cleared.gradingCompany, isNull);
      expect(cleared.certificationNumber, isNull);
      expect(cleared.signedBy, isNull);
    });

    test(
        'MovieOwnedDetails.copyWith allows preserving, updating, and clearing fields',
        () {
      final video = const MovieOwnedDetails(
        boxSetId: 'box-1',
        boxSetName: 'Trilogy Set',
        distributor: 'Criterion',
      );

      // Omitted -> preserve
      expect(video.copyWith().boxSetName, 'Trilogy Set');

      // Set -> replace
      expect(video.copyWith(boxSetName: 'Complete Collection').boxSetName,
          'Complete Collection');

      // Clear -> null
      final cleared = video.copyWith(
        boxSetId: null,
        boxSetName: null,
        distributor: null,
      );
      expect(cleared.boxSetId, isNull);
      expect(cleared.boxSetName, isNull);
      expect(cleared.distributor, isNull);
    });

    test(
        'MusicOwnedDetails.copyWith allows preserving, updating, and clearing fields',
        () {
      final music = const MusicOwnedDetails(
        storageDevice: 'Shelf A',
        storageSlot: 'Slot 42',
      );

      // Omitted -> preserve
      expect(music.copyWith().storageSlot, 'Slot 42');

      // Set -> replace
      expect(music.copyWith(storageSlot: 'Slot 99').storageSlot, 'Slot 99');

      // Clear -> null
      final cleared = music.copyWith(
        storageDevice: null,
        storageSlot: null,
      );
      expect(cleared.storageDevice, isNull);
      expect(cleared.storageSlot, isNull);
    });

    test(
        'GameOwnedDetails.copyWith allows preserving, updating, and clearing fields',
        () {
      final game = const GameOwnedDetails(
        completeness: 'CIB',
        priceChartingId: 'pc-123',
        valueIsLocked: true,
      );

      // Omitted -> preserve
      expect(game.copyWith().priceChartingId, 'pc-123');

      // Clear -> null
      final cleared = game.copyWith(
        completeness: null,
        priceChartingId: null,
        valueIsLocked: null,
      );
      expect(cleared.completeness, isNull);
      expect(cleared.priceChartingId, isNull);
      expect(cleared.valueIsLocked, isNull);
    });

    test(
        'WishlistItem.copyWith allows preserving, updating, and clearing fields',
        () {
      final wishlist = WishlistItem(
        id: 'wish-1',
        catalogRef: CatalogEntityRef(
          kind: CatalogMediaKind.book.apiValue,
          id: 'b-1',
          entityType: CatalogEntityType.work,
        ),
        targetPriceCents: 1500,
        currency: 'USD',
        notes: 'Hardcover preferred',
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
      );

      expect(wishlist.copyWith().targetPriceCents, 1500);
      expect(wishlist.copyWith(targetPriceCents: 2000).targetPriceCents, 2000);

      final cleared = wishlist.copyWith(
        targetPriceCents: null,
        currency: null,
        notes: null,
      );
      expect(cleared.targetPriceCents, isNull);
      expect(cleared.currency, isNull);
      expect(cleared.notes, isNull);
    });

    test(
        'TrackingEntry.copyWith allows preserving, updating, and clearing fields',
        () {
      final tracking = TrackingEntry(
        id: 'track-1',
        catalogRef: CatalogEntityRef(
          kind: CatalogMediaKind.movie.apiValue,
          id: 'm-1',
          entityType: CatalogEntityType.release,
        ),
        rating: 9,
        notes: 'Great movie',
        progressCurrent: 100,
        progressTotal: 100,
        updatedAt: DateTime.utc(2025, 1, 1),
      );

      expect(tracking.copyWith().rating, 9);
      expect(tracking.copyWith(rating: 10).rating, 10);

      final cleared = tracking.copyWith(
        rating: null,
        notes: null,
        progressCurrent: null,
        progressTotal: null,
      );
      expect(cleared.rating, isNull);
      expect(cleared.notes, isNull);
      expect(cleared.progressCurrent, isNull);
      expect(cleared.progressTotal, isNull);
    });

    test(
        'AppUpdateState.copyWith allows preserving, updating, and clearing nullable error and download path',
        () {
      const update = AppUpdateState(
        downloadedPath: '/tmp/update.zip',
        errorMessage: 'Network error',
      );

      expect(update.copyWith().errorMessage, 'Network error');
      expect(
          update.copyWith(errorMessage: 'Disk full').errorMessage, 'Disk full');

      final cleared = update.copyWith(
        downloadedPath: null,
        errorMessage: null,
        release: null,
      );
      expect(cleared.downloadedPath, isNull);
      expect(cleared.errorMessage, isNull);
      expect(cleared.release, isNull);
    });

    test('Patch tri-state correctly differentiates unchanged, set, and clear',
        () {
      const pUnchanged = Patch<String?>.unchanged();
      const pSet = Patch<String?>.set('hello');
      const pClear = Patch<String?>.clear();

      String apply(Patch<String?> patch, String current) {
        return patch.when(
          unchanged: () => current,
          set: (v) => v ?? 'was_null',
          clear: () => 'cleared',
        );
      }

      expect(apply(pUnchanged, 'initial'), 'initial');
      expect(apply(pSet, 'initial'), 'hello');
      expect(apply(pClear, 'initial'), 'cleared');
    });
  });
}
