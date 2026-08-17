/// Abstract interface for secure, local-only provider credentials.
abstract class ProviderCredentialStore {
  /// Read a credential by provider key.
  Future<String?> read(String key);

  /// Write/update a credential by provider key.
  Future<void> write(String key, String value);

  /// Delete a credential by provider key.
  Future<void> delete(String key);

  /// Check if a credential exists for a key.
  Future<bool> containsKey(String key);
}
