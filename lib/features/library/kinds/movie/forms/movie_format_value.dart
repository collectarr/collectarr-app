String? moviePhysicalFormatId(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return null;
  return switch (raw.toLowerCase()) {
    'dvd' => 'dvd',
    'blu-ray' || 'bluray' => 'blu-ray',
    'blu-ray 3d' => 'blu-ray-3d',
    '4k ultra hd blu-ray' || '4k uhd' || '4k-uhd' => '4k-uhd',
    'vhs' => 'vhs',
    'laserdisc' => 'laserdisc',
    'digital' => 'digital',
    _ => raw,
  };
}

String moviePhysicalFormatLabel(String? value) {
  final raw = value?.trim() ?? '';
  return switch (raw.toLowerCase()) {
    'dvd' => 'DVD',
    'blu-ray' || 'bluray' => 'Blu-ray',
    'blu-ray-3d' => 'Blu-ray 3D',
    '4k-uhd' || 'uhd' => '4K Ultra HD Blu-ray',
    'vhs' => 'VHS',
    'laserdisc' => 'LaserDisc',
    'digital' => 'Digital',
    _ => raw,
  };
}
