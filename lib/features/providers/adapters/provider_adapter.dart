import 'package:collectarr_app/features/providers/domain/contracts/provider_metadata_source.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';

/// Base marker/class for provider adapters.
abstract class ProviderAdapter implements ProviderRawMetadataSource {
  @override
  String get name => descriptor.name;

  ProviderId get id => ProviderId.requireValue(descriptor.name);

  ProviderConnector toConnector({
    PersonalListReadCapability? personalRead,
    PersonalListWriteCapability? personalWrite,
    ProviderAccountAuthorizationCapability? accountAuthorization,
    PersonalListFileImportCapability? personalListFileImport,
    IdentityCapability? identity,
    ImageCapability? images,
    BarcodeCapability? barcode,
  }) {
    return ProviderConnector(
      id: id,
      descriptor: descriptor,
      rawMetadata: this,
      personalRead: personalRead,
      personalWrite: personalWrite,
      accountAuthorization: accountAuthorization,
      personalListFileImport: personalListFileImport,
      identity: identity,
      images: images,
      barcode: barcode,
    );
  }
}
