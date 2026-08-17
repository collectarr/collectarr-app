import 'package:collectarr_app/features/providers/domain/contracts/metadata_provider.dart';

/// Base marker/class for provider adapters.
abstract class ProviderAdapter implements MetadataProvider {
  @override
  String get name => descriptor.name;
}
