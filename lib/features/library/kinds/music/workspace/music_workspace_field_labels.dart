String musicLiveStudioLabel(bool isLive) => isLive ? 'Live' : 'Studio';

Iterable<String> musicLiveStudioLabels(Iterable<bool> values) =>
    values.map(musicLiveStudioLabel);
