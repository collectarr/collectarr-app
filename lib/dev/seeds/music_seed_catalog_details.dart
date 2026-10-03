/// Seed-only Music album contents used by the development database.
///
/// The seed declarations stay compact while the encoder emits the same
/// contained `discs -> tracks` shape accepted by the Music Catalog Item
/// contract.
final class MusicSeedCatalogDetails {
  const MusicSeedCatalogDetails({
    this.tracks = const [],
    this.discs = const [],
    this.catalogNumber,
  });

  final List<MusicSeedTrack> tracks;
  final List<MusicSeedDisc> discs;
  final String? catalogNumber;

  Map<String, dynamic> toJson() {
    final tracksByDisc = <int, List<MusicSeedTrack>>{};
    for (final track in tracks) {
      tracksByDisc.putIfAbsent(track.discNumber ?? 1, () => []).add(track);
    }

    final declaredDiscs = <int, MusicSeedDisc>{
      for (final disc in discs)
        if (disc.discNumber != null) disc.discNumber!: disc,
    };
    final discNumbers =
        <int>{...tracksByDisc.keys, ...declaredDiscs.keys}.toList()..sort();
    final encodedDiscs = <Map<String, dynamic>>[];
    for (final discNumber in discNumbers) {
      final declared = declaredDiscs[discNumber];
      final discTracks = [
        ...?declared?.tracks,
        ...?tracksByDisc[discNumber],
      ];
      encodedDiscs.add({
        'disc_number': discNumber,
        if (declared?.name != null) 'title': declared!.name,
        if (discTracks.isNotEmpty)
          'tracks': [
            for (var index = 0; index < discTracks.length; index++)
              discTracks[index].toCatalogJson(index + 1),
          ],
      });
    }

    return {
      if (encodedDiscs.isNotEmpty) 'discs': encodedDiscs,
      if (catalogNumber != null) 'catalog_number': catalogNumber,
    };
  }
}

final class MusicSeedDisc {
  const MusicSeedDisc({
    this.discNumber,
    this.name,
    this.tracks = const [],
  });

  final int? discNumber;
  final String? name;
  final List<MusicSeedTrack> tracks;
}

final class MusicSeedTrack {
  const MusicSeedTrack({
    this.title,
    this.trackNumber,
    this.duration,
    this.artist,
    Object? position,
    this.durationSeconds,
    this.discNumber,
  }) : position = position == null ? null : '$position';

  final String? title;
  final String? trackNumber;
  final String? duration;
  final String? artist;
  final String? position;
  final int? durationSeconds;
  final int? discNumber;

  Map<String, dynamic> toCatalogJson(int positionOrder) {
    final durationMs = durationSeconds == null
        ? _durationToMilliseconds(duration ?? '')
        : durationSeconds! * 1000;
    return {
      'position': position ?? trackNumber ?? positionOrder.toString(),
      'position_order': positionOrder,
      'title': title?.trim().isNotEmpty == true ? title!.trim() : 'Track',
      if (artist?.trim().isNotEmpty == true) 'artist': artist!.trim(),
      if (durationMs != null) 'duration_ms': durationMs,
    };
  }
}

int? _durationToMilliseconds(String value) {
  final parts = value.split(':').map(int.tryParse).toList(growable: false);
  if (parts.isEmpty || parts.any((part) => part == null)) return null;
  var seconds = 0;
  for (final part in parts) {
    seconds = seconds * 60 + part!;
  }
  return seconds * 1000;
}
