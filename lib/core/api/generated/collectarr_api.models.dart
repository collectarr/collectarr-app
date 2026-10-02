List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }
  return [
    for (final entry in value)
      if (entry is Map<String, dynamic>) Map<String, dynamic>.from(entry),
  ];
}
