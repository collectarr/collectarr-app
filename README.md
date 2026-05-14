# Collectarr Flutter Client

Flutter client for Collectarr across web, Windows desktop, and Android.

## Development

```powershell
flutter pub get
dart run build_runner build
flutter analyze
flutter test
```

Run on web:

```powershell
flutter run -d chrome
```

The web build uses Drift with sqlite3 WASM and stores the local database in
IndexedDB. The canonical catalog cache can be rebuilt from the metadata API; old
browser-local sql.js data is not migrated when switching to the WASM database.

Run on Windows:

```powershell
flutter run -d windows
```
