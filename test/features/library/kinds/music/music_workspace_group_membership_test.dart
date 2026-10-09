import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/models/smart_list_criteria.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/generic/library_filters.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contained Music values place an album once in each matching bucket',
      () {
    final album = _mixedAlbum();
    final data = MusicWorkspaceData.fromMusic(album);
    final personal = const PersonalOverlay();
    final source = LibraryWorkspaceContext(
      item: WorkspaceItem(
        target: const CatalogTargetRef(
          CatalogItemRef(kind: CatalogMediaKind.music, id: 'deluxe'),
        ),
        kindPresentationData: data,
      ),
      personal: personal,
    );
    final registration = const MusicRegistration();
    final item = LibraryProjectionItem.fromShelf(source, registration);
    final dto = item.dto as MusicWorkspaceProjection;
    final context = LibraryProjectionContext<MusicWorkspaceProjection>(
      item: source.item,
      personal: personal,
      dto: dto,
    );
    final workspace = libraryKindWorkspaceForKind(CatalogMediaKind.music);
    final grouping = const LibraryGroupingEngine();

    void expectBucketsAndSingleMembership(
      String fieldId,
      Iterable<String> expected,
    ) {
      final groupId = workspace.fields.groups
          .singleWhere((group) => group.id.value == fieldId)
          .id;
      final buckets = grouping.bucketsForItem(item, registration, groupId);
      expect(buckets, unorderedEquals(expected));
      final entries = grouping.buildGroupEntries([item], registration, groupId);
      expect(entries.map((entry) => entry.bucket), unorderedEquals(expected));
      for (final entry in entries) {
        expect(entry.items, [item]);
      }
    }

    final formats = grouping.bucketsForItem(
      item,
      registration,
      MusicGroupIds.discFormat,
    );
    expect(formats, ['CD', 'Vinyl']);
    expect(MusicCatalogWorkspaceFields.discFormat.getValue(context), formats);
    expectBucketsAndSingleMembership(
      'music.disc.format_family',
      ['opticalDisc', 'vinyl'],
    );

    final formatGroups = grouping.buildGroupEntries(
      [item],
      registration,
      MusicGroupIds.discFormat,
    );
    expect(formatGroups.map((group) => group.bucket), ['CD', 'Vinyl']);
    for (final group in formatGroups) {
      expect(group.items, [item]);
    }

    final yearGroupId = workspace.fields.groups
        .singleWhere((group) => group.id.value == 'music.disc.recording_year')
        .id;
    final years = grouping.bucketsForItem(item, registration, yearGroupId);
    expect(years, unorderedEquals(['2024', '2025', '2026']));
    expect(MusicCatalogWorkspaceFields.recordingYear.getValue(context), {
      2024,
      2025,
      2026,
    });
    final yearGroups = grouping.buildGroupEntries(
      [item],
      registration,
      yearGroupId,
    );
    expect(yearGroups.map((group) => group.bucket), unorderedEquals(years));
    for (final group in yearGroups) {
      expect(group.items, [item]);
    }
    expectBucketsAndSingleMembership(
      'music.disc.recording_date',
      ['2024', '2025', '2026-02-18'],
    );
    expectBucketsAndSingleMembership(
      'music.disc.recording_month',
      ['02 - February'],
    );

    expectBucketsAndSingleMembership(
      'music.recording_location',
      ['Abbey Road', 'Wembley'],
    );
    expectBucketsAndSingleMembership('music.rpm', ['45']);
    expectBucketsAndSingleMembership('music.disc.spars', ['[None]']);
    expectBucketsAndSingleMembership('music.sound', ['ADD', 'DDD']);
    expectBucketsAndSingleMembership('music.vinyl_color', ['Red']);
    expectBucketsAndSingleMembership('music.track.composition', ['[None]']);

    expectBucketsAndSingleMembership(
      'music.disc.is_live',
      ['Live', 'Studio'],
    );
    expect(MusicCatalogWorkspaceFields.liveStudio.getValue(context), {
      true,
      false,
    });
    expectBucketsAndSingleMembership(
      'music.credit.contributor',
      ['Jane', 'John'],
    );
    expectBucketsAndSingleMembership(
      'music.credit.role',
      ['Conductor', 'Producer'],
    );
    expectBucketsAndSingleMembership('music.credit.instrument', ['Piano']);

    bool matchesDiscFormat(SmartListFieldOperator operator, String value) =>
        libraryFilterMatches(
          item,
          LibraryFilterSelection(
            fieldCriteria: {
              'music.disc.format': SmartListFieldCriterion(
                operator: operator,
                value: value,
              ),
            },
          ),
          filterDefinitions: libraryPresentationForKind(CatalogMediaKind.music)
              .filterDefinitions,
          fieldRegistry: workspace.fields.asStructural(),
        );

    expect(matchesDiscFormat(SmartListFieldOperator.equals, 'Vinyl'), isTrue);
    expect(
        matchesDiscFormat(SmartListFieldOperator.equals, 'Cassette'), isFalse);
    expect(matchesDiscFormat(SmartListFieldOperator.notEquals, 'CD'), isFalse);
    expect(matchesDiscFormat(SmartListFieldOperator.notEquals, 'Cassette'),
        isTrue);
  });
}

MusicAlbum _mixedAlbum() => MusicAlbum(
      title: 'Deluxe Edition',
      discs: [
        MusicDisc(
          id: const MusicDiscId('cd-one'),
          discNumber: 1,
          formatFamily: MusicDiscFormatFamily.opticalDisc,
          format: 'CD',
          soundTypes: const ['DDD', 'DDD'],
          recordingDate: const PartialDate(year: 2025),
          recordingLocations: const ['Abbey Road', 'Abbey Road'],
          isLive: false,
          credits: [_credit('producer', 'John', 'Producer')],
        ),
        MusicDisc(
          id: const MusicDiscId('cd-two'),
          discNumber: 2,
          formatFamily: MusicDiscFormatFamily.opticalDisc,
          format: 'CD',
          soundTypes: const ['ADD'],
          recordingDate: const PartialDate(year: 2026, month: 2, day: 18),
          recordingLocations: const ['Wembley'],
          isLive: true,
          credits: [
            _credit(
              'conductor',
              'Jane',
              'Conductor',
              instruments: const ['Piano'],
            ),
          ],
        ),
        MusicDisc(
          id: const MusicDiscId('vinyl'),
          discNumber: 3,
          formatFamily: MusicDiscFormatFamily.vinyl,
          format: 'Vinyl',
          recordingDate: const PartialDate(year: 2024),
          color: 'Red',
          rpm: '45',
        ),
      ],
    );

MusicCredit _credit(
  String id,
  String name,
  String role, {
  List<String> instruments = const [],
}) =>
    MusicCredit(
      id: MusicCreditId(id),
      name: name,
      role: role,
      instruments: instruments,
      sequence: 1,
    );
