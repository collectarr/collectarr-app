enum TrackingSourceType {
  physical('physical', 'Physical'),
  digital('digital', 'Digital'),
  streaming('streaming', 'Streaming');

  const TrackingSourceType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static TrackingSourceType? fromApiValue(String? value) {
    final normalized = normalizeTrackingSourceType(value);
    if (normalized == null) {
      return null;
    }
    for (final source in TrackingSourceType.values) {
      if (source.apiValue == normalized) {
        return source;
      }
    }
    return null;
  }
}

TrackingSourceType? trackingSourceTypeFromValue(Object? value) {
  if (value is TrackingSourceType) {
    return value;
  }
  if (value is String?) {
    return TrackingSourceType.fromApiValue(value);
  }
  return null;
}

String? trackingSourceTypeApiValue(Object? value) {
  return trackingSourceTypeFromValue(value)?.apiValue;
}

String? normalizeTrackingSourceType(String? value) {
  final normalized = value?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  switch (normalized) {
    case 'physical':
    case 'disc':
    case 'cd':
    case 'vinyl':
    case 'cassette':
    case 'blu-ray':
    case 'bluray':
    case 'dvd':
    case 'book':
    case 'paperback':
    case 'hardcover':
    case 'print':
    case 'cartridge':
      return TrackingSourceType.physical.apiValue;
    case 'digital':
    case 'digital-audio':
    case 'digital-book':
    case 'digital-comic':
    case 'digital-game':
    case 'ebook':
    case 'epub':
    case 'kindle':
    case 'download':
    case 'digital-download':
    case 'file':
    case 'files':
      return TrackingSourceType.digital.apiValue;
    case 'streaming':
    case 'streamed':
    case 'stream':
    case 'subscription':
      return TrackingSourceType.streaming.apiValue;
    default:
      return null;
  }
}

String trackingSourceTypeLabel(Object? value) {
  return trackingSourceTypeFromValue(value)?.label ?? 'Unknown';
}