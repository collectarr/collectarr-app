Map<String, dynamic> jsonObject(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> jsonObjectList(Object? value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value
      .whereType<Map<String, dynamic>>()
      .map(Map<String, dynamic>.from)
      .toList();
}
