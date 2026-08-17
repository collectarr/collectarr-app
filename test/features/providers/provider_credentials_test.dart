import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSecureStorage extends FlutterSecureStorage {
  _FakeSecureStorage() : super();

  final Map<String, String> _data = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }

  @override
  Future<bool> containsKey({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data.containsKey(key);
  }
}

void main() {
  group('Provider Credentials Models', () {
    test('ComicVineCredentials validates and serializes', () {
      const creds = ComicVineCredentials(apiKey: 'cv_api_key_123');
      expect(creds.isValid, isTrue);
      expect(const ComicVineCredentials(apiKey: '').isValid, isFalse);

      final json = creds.toJson();
      expect(ComicVineCredentials.fromJson(json), equals(creds));
    });

    test('HardcoverCredentials validates and serializes', () {
      const creds = HardcoverCredentials(apiKey: 'hc_bearer_token_abc');
      expect(creds.isValid, isTrue);
      expect(const HardcoverCredentials(apiKey: '  ').isValid, isFalse);

      final json = creds.toJson();
      expect(HardcoverCredentials.fromJson(json), equals(creds));
    });

    test('TmdbCredentials supports read access token and api key', () {
      const tokenCreds = TmdbCredentials(readAccessToken: 'eyJhbGciOi...');
      expect(tokenCreds.isValid, isTrue);

      const keyCreds = TmdbCredentials(apiKey: 'tmdb_v3_key');
      expect(keyCreds.isValid, isTrue);

      const emptyCreds = TmdbCredentials();
      expect(emptyCreds.isValid, isFalse);

      expect(TmdbCredentials.fromJson(tokenCreds.toJson()), equals(tokenCreds));
      expect(TmdbCredentials.fromJson(keyCreds.toJson()), equals(keyCreds));
    });

    test('BggCredentials validates and serializes', () {
      const creds = BggCredentials(apiToken: 'bgg_token_123');
      expect(creds.isValid, isTrue);
      expect(const BggCredentials().isValid, isFalse);

      final json = creds.toJson();
      expect(BggCredentials.fromJson(json), equals(creds));
    });

    test('IgdbCredentials requires both client ID and user access token', () {
      const creds = IgdbCredentials(
        clientId: 'twitch_client_id',
        userAccessToken: 'twitch_user_token',
      );
      expect(creds.isValid, isTrue);

      const missingToken = IgdbCredentials(
        clientId: 'twitch_client_id',
        userAccessToken: '',
      );
      expect(missingToken.isValid, isFalse);

      final json = creds.toJson();
      expect(IgdbCredentials.fromJson(json), equals(creds));
    });
  });

  group('SecureProviderCredentialStore', () {
    late SecureProviderCredentialStore store;
    late _FakeSecureStorage fakeStorage;

    setUp(() {
      fakeStorage = _FakeSecureStorage();
      store = SecureProviderCredentialStore(storage: fakeStorage);
    });

    test('stores, retrieves, and clears credentials across all providers',
        () async {
      expect(await store.getComicVineCredentials(), isNull);
      expect(await store.getHardcoverCredentials(), isNull);
      expect(await store.getTmdbCredentials(), isNull);
      expect(await store.getBggCredentials(), isNull);
      expect(await store.getIgdbCredentials(), isNull);

      // Comic Vine
      await store.setComicVineCredentials(
          const ComicVineCredentials(apiKey: 'cv-key-1'));
      expect((await store.getComicVineCredentials())?.apiKey, 'cv-key-1');
      await store.clearComicVineCredentials();
      expect(await store.getComicVineCredentials(), isNull);

      // Hardcover
      await store.setHardcoverCredentials(
          const HardcoverCredentials(apiKey: 'hc-key-1'));
      expect((await store.getHardcoverCredentials())?.apiKey, 'hc-key-1');

      // TMDb
      await store.setTmdbCredentials(
          const TmdbCredentials(readAccessToken: 'tmdb-token-1'));
      expect(
          (await store.getTmdbCredentials())?.readAccessToken, 'tmdb-token-1');

      // BGG
      await store
          .setBggCredentials(const BggCredentials(apiToken: 'bgg-tok-1'));
      expect((await store.getBggCredentials())?.apiToken, 'bgg-tok-1');

      // IGDB
      await store.setIgdbCredentials(const IgdbCredentials(
        clientId: 'igdb-id',
        userAccessToken: 'igdb-tok',
      ));
      final igdb = await store.getIgdbCredentials();
      expect(igdb?.clientId, 'igdb-id');
      expect(igdb?.userAccessToken, 'igdb-tok');

      // Clear all
      await store.clearAll();
      expect(await store.getHardcoverCredentials(), isNull);
      expect(await store.getTmdbCredentials(), isNull);
      expect(await store.getBggCredentials(), isNull);
      expect(await store.getIgdbCredentials(), isNull);
    });

    test('maskSecret produces bulleted strings retaining only visible suffix',
        () {
      expect(SecureProviderCredentialStore.maskSecret(null), '');
      expect(SecureProviderCredentialStore.maskSecret(''), '');
      expect(SecureProviderCredentialStore.maskSecret('123'), '•••');
      expect(SecureProviderCredentialStore.maskSecret('abcdefgh'), '••••efgh');
      expect(
        SecureProviderCredentialStore.maskSecret('sk-live-12345678',
            visibleSuffixLength: 4),
        '••••••••••••5678',
      );
    });
  });
}
