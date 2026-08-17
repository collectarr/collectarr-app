import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_provider_credential_store.dart';

/// Provider for the secure, local-only provider credential store.
final providerCredentialStoreProvider =
    Provider<SecureProviderCredentialStore>((ref) {
  return SecureProviderCredentialStore();
});
