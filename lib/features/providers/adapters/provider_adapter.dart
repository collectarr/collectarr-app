import 'package:collectarr_app/features/providers/domain/contracts/metadata_provider.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';

/// Base marker/class for provider adapters.
abstract class ProviderAdapter implements MetadataProvider, MetadataCapability {
  @override
  String get name => descriptor.name;

  ProviderId get id =>
      ProviderId.fromValue(descriptor.name) ?? ProviderId.tmdb;

  ProviderConnector toConnector({
    PersonalListReadCapability? personalRead,
    PersonalListWriteCapability? personalWrite,
    FileImportCapability? fileImport,
    IdentityCapability? identity,
    ImageCapability? images,
    BarcodeCapability? barcode,
  }) {
    return ProviderConnector(
      id: id,
      descriptor: descriptor,
      metadata: this,
      personalRead: personalRead,
      personalWrite: personalWrite,
      fileImport: fileImport,
      identity: identity,
      images: images,
      barcode: barcode,
    );
  }
}
