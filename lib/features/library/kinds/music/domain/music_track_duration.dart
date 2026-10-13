/// Parses a track duration as seconds, MM:SS, or HH:MM:SS.
int? parseMusicTrackDurationMs(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return null;
  final parts = normalized.split(':');
  if (parts.length == 1) {
    final seconds = double.tryParse(parts.single);
    return seconds == null || seconds < 0 ? null : (seconds * 1000).round();
  }
  if (parts.length == 2) {
    final minutes = int.tryParse(parts[0]);
    final seconds = int.tryParse(parts[1]);
    if (minutes == null ||
        seconds == null ||
        minutes < 0 ||
        seconds < 0 ||
        seconds >= 60) {
      return null;
    }
    return (minutes * 60 + seconds) * 1000;
  }
  if (parts.length == 3) {
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    final seconds = int.tryParse(parts[2]);
    if (hours == null ||
        minutes == null ||
        seconds == null ||
        hours < 0 ||
        minutes < 0 ||
        minutes >= 60 ||
        seconds < 0 ||
        seconds >= 60) {
      return null;
    }
    return (hours * 3600 + minutes * 60 + seconds) * 1000;
  }
  return null;
}

String? formatMusicTrackDuration(int? durationMs) {
  if (durationMs == null || durationMs < 0) return null;
  final totalSeconds = (durationMs / 1000).round();
  final minutes = totalSeconds ~/ 60;
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
