import 'package:collectarr_app/core/models/json_encodable.dart';

/// Empty details used only by cross-kind tests that exercise structural
/// infrastructure. It is not a production owned-item domain type.
final class TestOwnedDetails implements JsonEncodable {
  const TestOwnedDetails();

  @override
  Map<String, dynamic> toJson() => const <String, dynamic>{};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TestOwnedDetails;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class TestOwnedDetailsDraft implements JsonEncodable {
  const TestOwnedDetailsDraft();

  @override
  Map<String, dynamic> toJson() => const <String, dynamic>{};

  TestOwnedDetails toDetails() => const TestOwnedDetails();
}
