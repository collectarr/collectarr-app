import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate' as isolate;

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
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_facts.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

const _runBenchmark = bool.fromEnvironment('RUN_MUSIC_WORKSPACE_BENCHMARK');
const _selectedAlbumCount =
    int.fromEnvironment('MUSIC_WORKSPACE_BENCHMARK_ALBUMS');
const _repeatCount = 3;

void main() {
  test(
    'Music workspace projection, facts, grouping, sorting, and filtering benchmark',
    () async {
      final allocationProfiler = await _VmAllocationProfiler.connect();
      try {
        final albumCounts = _selectedAlbumCount == 0
            ? const [1000, 5000]
            : [_selectedAlbumCount];
        if (albumCounts.any((count) => count != 1000 && count != 5000)) {
          throw ArgumentError.value(
            _selectedAlbumCount,
            'MUSIC_WORKSPACE_BENCHMARK_ALBUMS',
            'must be 1000, 5000, or unset',
          );
        }
        for (final albumCount in albumCounts) {
          final albums = _benchmarkAlbums(albumCount);
          _warmUp(albums.take(200).toList(growable: false));
          final beforeProjectionRss = ProcessInfo.currentRss;
          final beforeProjectionPeak = ProcessInfo.maxRss;
          await allocationProfiler.reset();
          final items = _projectAlbums(albums);
          final projectionAllocations = await allocationProfiler.read();
          final afterProjectionRss = ProcessInfo.currentRss;
          final afterProjectionPeak = ProcessInfo.maxRss;
          _verifyProjectionFactsAreReused(items);
          final projectionTime = _measureProjection(albums);

          final workspace = libraryKindWorkspaceForKind(CatalogMediaKind.music);
          final registration = const MusicRegistration();
          final groupTimes = <String, int>{};
          for (final fieldId in [
            'music.disc.recording_year',
            'music.disc.spars',
            'music.recording_location',
          ]) {
            final groupId = workspace.fields.groups
                .singleWhere((group) => group.id.value == fieldId)
                .id;
            groupTimes[fieldId] = _measureAverage(() {
              final buckets = const LibraryGroupingEngine().buildBuckets(
                items,
                registration,
                groupId,
              );
              return buckets.length;
            });
          }

          final sortTime = _measureAverage(() {
            final sorted = List<LibraryProjectionItem>.of(items);
            sorted.sort((left, right) => workspace.fields.compareEntries(
                  left,
                  right,
                  workspace.fields.defaultSort,
                ));
            return sorted.length;
          });

          final filterEngine = const LibraryFilterEngine();
          const searchDocument = LibrarySearchDocument(
            itemId: 'benchmark',
            normalizedTokens: [],
          );
          const discFormatQuery = LibraryProjectionQuery(
            filterSelection: LibraryFilterSelection(
              fieldCriteria: {
                'music.disc.format': SmartListFieldCriterion(
                  operator: SmartListFieldOperator.equals,
                  value: 'CD',
                ),
              },
            ),
          );
          const publisherQuery = LibraryProjectionQuery(
            filterSelection: LibraryFilterSelection(
              fieldCriteria: {
                'music.publisher': SmartListFieldCriterion(
                  operator: SmartListFieldOperator.equals,
                  value: 'Label 1',
                ),
              },
            ),
          );
          final discFormatFilterTime = _measureAverage(() {
            var matched = 0;
            for (final item in items) {
              if (filterEngine.matches(
                item: item,
                query: discFormatQuery,
                searchDoc: searchDocument,
                type: registration,
              )) {
                matched++;
              }
            }
            return matched;
          });
          final publisherFilterTime = _measureAverage(() {
            var matched = 0;
            for (final item in items) {
              if (filterEngine.matches(
                item: item,
                query: publisherQuery,
                searchDoc: searchDocument,
                type: registration,
              )) {
                matched++;
              }
            }
            return matched;
          });

          final afterAllPeak = ProcessInfo.maxRss;
          final factsTime = _measureFacts(albums);
          stdout.writeln(jsonEncode({
            'albums': albumCount,
            'discs': albums.fold<int>(
              0,
              (total, album) => total + album.discs.length,
            ),
            'factsConstructionMs': _milliseconds(factsTime),
            'initialProjectionMs': _milliseconds(projectionTime),
            'averageGroupSwitchMs': {
              for (final entry in groupTimes.entries)
                entry.key: _milliseconds(entry.value),
            },
            'averageSortMs': _milliseconds(sortTime),
            'averageDiscFormatFilterMs': _milliseconds(discFormatFilterTime),
            'averagePublisherFilterMs': _milliseconds(publisherFilterTime),
            'rssBeforeProjectionBytes': beforeProjectionRss,
            'rssAfterProjectionBytes': afterProjectionRss,
            'rssDeltaBytes': afterProjectionRss - beforeProjectionRss,
            'peakRssBeforeProjectionBytes': beforeProjectionPeak,
            'peakRssAfterProjectionBytes': afterProjectionPeak,
            'singleProjectionPeakIncreaseBytes':
                afterProjectionPeak - beforeProjectionPeak,
            'peakRssAfterWorkspaceOpsBytes': afterAllPeak,
            'peakRssIncreaseBytes': afterAllPeak - beforeProjectionPeak,
            // VM Service counters are isolate-local and include the small
            // benchmark/service overhead around the measured projection.
            'projectionAllocatedBytes': projectionAllocations.allocatedBytes,
            'projectionAllocatedInstances':
                projectionAllocations.allocatedInstances,
          }));
        }
      } finally {
        await allocationProfiler.dispose();
      }
    },
    skip: !_runBenchmark,
  );
}

final class _VmAllocationProfiler {
  _VmAllocationProfiler(this._service, this._isolateId);

  final VmService _service;
  final String _isolateId;

  static Future<_VmAllocationProfiler> connect() async {
    var info = await developer.Service.getInfo();
    if (info.serverWebSocketUri == null) {
      info = await developer.Service.controlWebServer(
        enable: true,
        silenceOutput: true,
      );
    }
    final websocketUri = info.serverWebSocketUri;
    final isolateId = developer.Service.getIsolateId(isolate.Isolate.current);
    if (websocketUri == null || isolateId == null) {
      throw StateError(
        'The Music workspace benchmark requires the Dart VM service.',
      );
    }
    return _VmAllocationProfiler(
      await vmServiceConnectUri(websocketUri.toString()),
      isolateId,
    );
  }

  Future<void> reset() async {
    await _service.getAllocationProfile(_isolateId, reset: true);
  }

  Future<_AllocationTotals> read() async {
    final profile = await _service.getAllocationProfile(_isolateId);
    final classes = profile.members ?? const [];
    return _AllocationTotals(
      allocatedBytes: classes.fold<int>(
        0,
        (total, stats) => total + (stats.accumulatedSize ?? 0),
      ),
      allocatedInstances: classes.fold<int>(
        0,
        (total, stats) => total + (stats.instancesAccumulated ?? 0),
      ),
    );
  }

  Future<void> dispose() => _service.dispose();
}

final class _AllocationTotals {
  const _AllocationTotals({
    required this.allocatedBytes,
    required this.allocatedInstances,
  });

  final int allocatedBytes;
  final int allocatedInstances;
}

int _measureFacts(List<MusicAlbum> albums) {
  var count = 0;
  final stopwatch = Stopwatch()..start();
  for (var run = 0; run < _repeatCount; run++) {
    for (final album in albums) {
      count += MusicWorkspaceFacts.fromAlbum(album).discCount;
    }
  }
  stopwatch.stop();
  expect(count, greaterThan(0));
  return stopwatch.elapsedMicroseconds ~/ _repeatCount;
}

int _measureAverage(int Function() action) {
  var checksum = 0;
  final stopwatch = Stopwatch()..start();
  for (var run = 0; run < _repeatCount; run++) {
    checksum += action();
  }
  stopwatch.stop();
  expect(checksum, greaterThan(0));
  return stopwatch.elapsedMicroseconds ~/ _repeatCount;
}

List<LibraryProjectionItem> _projectAlbums(List<MusicAlbum> albums) {
  final registration = const MusicRegistration();
  final personal = const PersonalOverlay();
  return [
    for (var index = 0; index < albums.length; index++)
      _projectAlbum(albums[index], index, registration, personal),
  ];
}

int _measureProjection(
  List<MusicAlbum> albums,
) {
  final durations = <int>[];
  for (var run = 0; run < _repeatCount; run++) {
    final stopwatch = Stopwatch()..start();
    final items = _projectAlbums(albums);
    stopwatch.stop();
    if (items.length != albums.length) {
      throw StateError('Projection benchmark dropped Music albums.');
    }
    durations.add(stopwatch.elapsedMicroseconds);
  }
  durations.sort();
  return durations[durations.length ~/ 2];
}

LibraryProjectionItem _projectAlbum(
  MusicAlbum album,
  int index,
  MusicRegistration registration,
  PersonalOverlay personal,
) {
  final data = MusicWorkspaceData.fromMusic(album);
  final context = LibraryWorkspaceContext(
    item: WorkspaceItem(
      target: CatalogTargetRef(
        CatalogItemRef(kind: CatalogMediaKind.music, id: 'benchmark-$index'),
      ),
      kindPresentationData: data,
    ),
    personal: personal,
  );
  return LibraryProjectionItem.fromShelf(context, registration);
}

void _verifyProjectionFactsAreReused(List<LibraryProjectionItem> items) {
  for (final item in items) {
    final data = item.source.item.kindPresentationData;
    if (data is! MusicWorkspaceData ||
        !identical((item.dto as MusicWorkspaceProjection).facts, data.facts)) {
      throw StateError(
        'Workspace projection rebuilt MusicWorkspaceFacts for ${item.target.id}.',
      );
    }
  }
}

List<MusicAlbum> _benchmarkAlbums(int count) => [
      for (var albumIndex = 0; albumIndex < count; albumIndex++)
        _benchmarkAlbum(albumIndex),
    ];

void _warmUp(List<MusicAlbum> albums) {
  final items = _projectAlbums(albums);
  final workspace = libraryKindWorkspaceForKind(CatalogMediaKind.music);
  final registration = const MusicRegistration();
  for (final fieldId in [
    'music.disc.recording_year',
    'music.disc.spars',
    'music.recording_location',
  ]) {
    final groupId = workspace.fields.groups
        .singleWhere((group) => group.id.value == fieldId)
        .id;
    const LibraryGroupingEngine().buildBuckets(items, registration, groupId);
  }
  final sorted = List<LibraryProjectionItem>.of(items)
    ..sort((left, right) => workspace.fields.compareEntries(
          left,
          right,
          workspace.fields.defaultSort,
        ));
  expect(sorted, hasLength(items.length));
  final filterEngine = const LibraryFilterEngine();
  const searchDocument = LibrarySearchDocument(
    itemId: 'benchmark',
    normalizedTokens: [],
  );
  const filterQuery = LibraryProjectionQuery(
    filterSelection: LibraryFilterSelection(
      fieldCriteria: {
        'music.disc.format': SmartListFieldCriterion(
          operator: SmartListFieldOperator.equals,
          value: 'CD',
        ),
      },
    ),
  );
  for (final item in items) {
    filterEngine.matches(
      item: item,
      query: filterQuery,
      searchDoc: searchDocument,
      type: registration,
    );
  }
}

MusicAlbum _benchmarkAlbum(int albumIndex) {
  final discCount = albumIndex % 100 == 0 ? 8 : 2 + albumIndex % 3;
  return MusicAlbum(
    title: 'Benchmark Album $albumIndex',
    artist: 'Artist ${albumIndex % 200}',
    publisher: 'Label ${albumIndex % 32}',
    countryCode: albumIndex.isEven ? 'GB' : 'US',
    genres: [
      'Genre ${albumIndex % 12}',
      'Genre ${(albumIndex + 1) % 12}',
    ],
    discs: [
      for (var discIndex = 0; discIndex < discCount; discIndex++)
        _benchmarkDisc(albumIndex, discIndex),
    ],
  );
}

MusicDisc _benchmarkDisc(int albumIndex, int discIndex) {
  final family = MusicDiscFormatFamily.values[discIndex % 3];
  final formats = switch (family) {
    MusicDiscFormatFamily.vinyl => 'Vinyl',
    MusicDiscFormatFamily.opticalDisc => 'CD',
    MusicDiscFormatFamily.tape => 'Cassette',
    _ => 'Other',
  };
  return MusicDisc(
    id: MusicDiscId('benchmark-$albumIndex-disc-$discIndex'),
    discNumber: discIndex + 1,
    formatFamily: family,
    format: formats,
    soundTypes: [
      ['ADD', 'DDD', 'AAD'][discIndex % 3]
    ],
    recordingDate: PartialDate(
      year: 1990 + (albumIndex + discIndex) % 35,
      month: 1 + (discIndex % 12),
    ),
    recordingLocations: ['Studio ${discIndex % 10}'],
    isLive: discIndex.isOdd,
    sparsCode: ['ADD', 'DDD', 'AAD'][discIndex % 3],
    color: family == MusicDiscFormatFamily.vinyl ? 'Red' : null,
    rpm: family == MusicDiscFormatFamily.vinyl ? '45' : null,
    credits: [
      MusicCredit(
        id: MusicCreditId('benchmark-$albumIndex-credit-$discIndex'),
        name: 'Contributor ${(albumIndex + discIndex) % 400}',
        role: ['Producer', 'Conductor', 'Engineer'][discIndex % 3],
        instruments: ['Piano'],
        sequence: 1,
      ),
    ],
    tracks: [
      for (var trackIndex = 0; trackIndex < 10; trackIndex++)
        MusicTrack(
          id: MusicTrackId(
            'benchmark-$albumIndex-disc-$discIndex-track-$trackIndex',
          ),
          position: '${trackIndex + 1}',
          positionOrder: trackIndex,
          title: 'Track $trackIndex',
          composition: 'Composition ${trackIndex % 30}',
          durationMs: 180000 + trackIndex * 1000,
        ),
    ],
  );
}

double _milliseconds(int microseconds) => microseconds / 1000;
