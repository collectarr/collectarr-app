import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/comics/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('comics library config groups reusable media behavior', () {
    expect(comicsLibraryConfig.workspace.kind, 'comic');
    expect(comicsLibraryConfig.singularLabel, 'Comic');
    expect(comicsLibraryConfig.pluralLabel, 'Comics');
    expect(comicsLibraryConfig.defaultMetadataProvider, 'gcd');
    expect(comicsLibraryConfig.defaultSupportedMetadataProvider, 'gcd');
    expect(
        comicsLibraryConfig.defaultSupportedMetadataProviderOption?.id, 'gcd');
    expect(comicsLibraryConfig.supportsMetadataProvider('gcd'), isTrue);
    expect(comicsLibraryConfig.supportsMetadataProvider('comicvine'), isTrue);
    expect(
      comicsLibraryConfig.defaultMetadataProviderOption?.usagePolicy?.summary,
      contains('CC BY-SA'),
    );
    expect(
      comicsLibraryConfig.metadataProviders
          .where((provider) => provider.requiresApiKey)
          .single
          .id,
      'comicvine',
    );
    expect(comicsLibraryConfig.metadataProviderLabel('gcd'), 'GCD');
    expect(
      comicsLibraryConfig.metadataProviderLabel('comicvine'),
      'Comic Vine',
    );
    expect(
      comicsLibraryConfig.metadataProviderLabel('unknown-provider'),
      'unknown-provider',
    );
    expect(comicsLibraryConfig.trackingProfile, comicTrackingProfile);
    expect(comicsLibraryConfig.countLabel(1), 'Comic');
    expect(comicsLibraryConfig.countLabel(2), 'Comics');
  });

  test('library type registry resolves supported media kinds and providers',
      () {
    expect(collectarrLibraryTypes.supportedKinds, [
      'comic',
      'game',
      'bluray',
    ]);
    expect(collectarrLibraryTypes.byKind('comic'), comicsLibraryConfig);
    expect(collectarrLibraryTypes.byKind(' Comic '), comicsLibraryConfig);
    expect(
        collectarrLibraryTypes.byKind('game')?.defaultMetadataProvider, 'igdb');
    expect(collectarrLibraryTypes.byKind('bluray')?.defaultMetadataProvider,
        'tmdb');
    expect(collectarrLibraryTypes.byKind('book'), isNull);
    expect(
      collectarrLibraryTypes.providersForKind('comic').map((row) => row.id),
      ['gcd', 'comicvine'],
    );
    expect(
      collectarrLibraryTypes.providersForKind('game').map((row) => row.id),
      ['igdb'],
    );
    expect(
      collectarrLibraryTypes.providersForKind('bluray').map((row) => row.id),
      ['tmdb'],
    );
    expect(collectarrLibraryTypes.providersForKind('book'), isEmpty);
  });

  test('comics media adapter exposes reusable workspace table behavior', () {
    expect(comicsMediaAdapter.type, comicsLibraryConfig);
    expect(comicsMediaAdapter.viewProfile.config.kind, 'comic');
    expect(comicsMediaAdapter.columnDisplayName(LibraryTableColumn.title),
        'Series');
    expect(comicsMediaAdapter.columnLabel(LibraryTableColumn.cover), '');
    expect(
      comicsMediaAdapter.columnGroup(LibraryTableColumn.storageBox),
      LibraryTableColumnGroup.personal,
    );
    expect(
        comicsMediaAdapter.columnIsNumeric(LibraryTableColumn.price), isTrue);
    expect(
      comicsMediaAdapter.columnSort(LibraryTableColumn.releaseDate),
      LibrarySortColumn.releaseDate,
    );
    expect(
      comicsMediaAdapter.orderedTableColumns(const {}).first,
      LibraryTableColumn.status,
    );
  });
}
