import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/entries/game_hardware_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/entries/game_toy_library_entry_update_payload.dart';
import 'package:flutter_test/flutter_test.dart';

const _yearOnly = PartialDate(year: 2014);
final _full = DateTime.utc(2014, 11, 14);
const _fullParts = PartialDate(year: 2014, month: 11, day: 14);
final _changed = DateTime.utc(2026, 10, 23);
final _now = DateTime.utc(2026, 10, 23, 12);

typedef _Apply = (DateTime?, PartialDate?) Function(
    Patch<DateTime?> patch, DateTime? date, PartialDate? parts);

(DateTime?, PartialDate?) _game(
    Patch<DateTime?> patch, DateTime? date, PartialDate? parts) {
  final existing = GameLibraryEntry(
    id: const LibraryEntryId('game'),
    metadata: const GameCatalogMetadata(title: 'Fictional Game'),
    personal: GamePersonalData(purchaseDate: date, purchaseDateParts: parts),
    updatedAt: DateTime.utc(2026),
  );
  final personal = GameLibraryEntryUpdatePayload.partial(purchaseDate: patch)
      .applyTo(existing,
          updatedAt: _now, fallbackOwnerUserId: null, fallbackOwnerLabel: null)
      .personal;
  return (personal.purchaseDate, personal.purchaseDateParts);
}

(DateTime?, PartialDate?) _hardware(
    Patch<DateTime?> patch, DateTime? date, PartialDate? parts) {
  final existing = GameHardwareLibraryEntry(
    id: const LibraryEntryId('hardware'),
    metadata: const GameHardwareCatalogMetadata(title: 'Fictional Console'),
    personal:
        GameHardwarePersonalData(purchaseDate: date, purchaseDateParts: parts),
    updatedAt: DateTime.utc(2026),
  );
  final personal =
      GameHardwareLibraryEntryUpdatePayload.partial(purchaseDate: patch)
          .applyTo(existing,
              updatedAt: _now,
              fallbackOwnerUserId: null,
              fallbackOwnerLabel: null)
          .personal;
  return (personal.purchaseDate, personal.purchaseDateParts);
}

(DateTime?, PartialDate?) _toy(
    Patch<DateTime?> patch, DateTime? date, PartialDate? parts) {
  final existing = GameToyLibraryEntry(
    id: const LibraryEntryId('toy'),
    metadata: const GameToyCatalogMetadata(title: 'Fictional Figure'),
    personal: GameToyPersonalData(purchaseDate: date, purchaseDateParts: parts),
    updatedAt: DateTime.utc(2026),
  );
  final personal = GameToyLibraryEntryUpdatePayload.partial(purchaseDate: patch)
      .applyTo(existing,
          updatedAt: _now, fallbackOwnerUserId: null, fallbackOwnerLabel: null)
      .personal;
  return (personal.purchaseDate, personal.purchaseDateParts);
}

void main() {
  final kinds = <String, _Apply>{
    'Games': _game,
    'Hardware': _hardware,
    'Toys': _toy,
  };
  for (final MapEntry(key: kind, value: apply) in kinds.entries) {
    group('$kind purchase date patch', () {
      test('unchanged keeps both representations', () {
        expect(
            apply(const Patch.unchanged(), null, _yearOnly), (null, _yearOnly));
        expect(apply(const Patch.unchanged(), _full, _fullParts),
            (_full, _fullParts));
      });

      test('re-sending the same date keeps a year-only date', () {
        expect(apply(Patch.set(null), null, _yearOnly), (null, _yearOnly));
        expect(apply(Patch.set(_full), _full, _fullParts), (_full, _fullParts));
      });

      test('a new date updates both representations', () {
        const changedParts = PartialDate(year: 2026, month: 10, day: 23);
        expect(apply(Patch.set(_changed), null, _yearOnly),
            (_changed, changedParts));
        expect(apply(Patch.set(_changed), _full, _fullParts),
            (_changed, changedParts));
      });

      test('clear removes both representations', () {
        expect(apply(const Patch.clear(), null, _yearOnly), (null, null));
        expect(apply(Patch.set(null), _full, _fullParts), (null, null));
      });
    });
  }
}
