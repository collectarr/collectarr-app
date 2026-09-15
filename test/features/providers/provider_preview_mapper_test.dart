import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';
import 'package:collectarr_app/features/providers/transport/provider_preview_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('provider preview preserves Music disc numbers on tracks', () {
    const envelope = ProviderMetadataEnvelope(
      provider: 'musicbrainz',
      providerItemId: 'release-1',
      kind: CatalogMediaKind.music,
      payload: ProviderMetadataPayload({
        'title': 'Multidisc album',
        'tracks': [
          {'position': 1, 'title': 'Side A', 'disc_number': 1},
          {'position': 1, 'title': 'Side B', 'disc_number': 2},
        ],
      }),
      provenance: ProviderProvenance(fetchedAt: ''),
      images: [],
      attribution: ProviderAttribution(required: false),
    );

    final preview = providerPreviewFromEnvelope(envelope);

    expect(
      preview.tracks.map((track) => track.discNumber),
      [1, 2],
    );
  });
}
