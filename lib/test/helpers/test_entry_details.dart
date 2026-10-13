import 'package:collectarr_app/core/models/json_encodable.dart';

/// Empty details used only by cross-kind tests that exercise structural
/// infrastructure. It is not a production entry-item domain type.
final class TestEntryDetails implements JsonEncodable {
  const TestEntryDetails();

  @override
  Map<String, dynamic> toJson() => const <String, dynamic>{};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TestEntryDetails;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class TestEntryDetailsDraft implements JsonEncodable {
  const TestEntryDetailsDraft();

  @override
  Map<String, dynamic> toJson() => const <String, dynamic>{};

  TestEntryDetails toDetails() => const TestEntryDetails();
}
