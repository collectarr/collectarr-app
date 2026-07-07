import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/music/music_domain.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('music work maps metadata into a workspace entry', () {
    final work = MusicWork.fromMetadataItem(
      LibraryMetadataItem(
        id: 'music-1',
        kind: 'music',
        title: 'Kinesis',
        displayTitle: 'Kinesis',
        publisher: 'Inside Out',
        releaseDate: DateTime.utc(1998, 1, 1),
        releaseYear: 1998,
        barcode: '1234567890',
        variant: 'CD',
        editions: const [
          CatalogEdition(
            id: 'edition-1',
            title: 'CD',
            publisher: 'Inside Out',
            upc: '1234567890',
          ),
        ],
        music: const MusicCatalogDetails(
          trackCount: 3,
          catalogNumber: 'KDCD 1022',
          releaseStatus: 'Album',
        ),
      ),
    );

    final entry = buildMusicWorkspaceEntry(work, const MusicPersonalOverlay())
        as MusicWorkspaceEntry;

    expect(entry.title, 'Kinesis');
    expect(entry.music?.catalogNumber, 'KDCD 1022');
    expect(entry.editions, hasLength(1));
    expect(entry.editions.first.title, 'CD');
    expect(work.displayEditionLabel, 'CD');
    expect(work.hasMissingCoreMetadata, isFalse);
  });
}
