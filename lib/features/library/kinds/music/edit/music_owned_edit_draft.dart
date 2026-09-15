import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_disc_storage.dart';

final class MusicOwnedEditDraft {
  MusicOwnedEditDraft.fromDetails(MusicOwnedDetails details)
      : original = details,
        storageDevice = details.storageDevice,
        storageSlot = details.storageSlot,
        signedBy = details.signedBy,
        lastCleanedDate = details.lastCleanedDate,
        matrixRunouts = List<MusicMatrixRunout>.from(details.matrixRunouts),
        discStorage = List<MusicDiscStorage>.from(details.discStorage);

  final MusicOwnedDetails original;
  String? storageDevice;
  String? storageSlot;
  String? signedBy;
  DateTime? lastCleanedDate;
  List<MusicMatrixRunout> matrixRunouts;
  List<MusicDiscStorage> discStorage;

  MusicOwnedDetails toDetails() => MusicOwnedDetails(
        storageDevice: _text(storageDevice),
        storageSlot: _text(storageSlot),
        signedBy: _text(signedBy),
        lastCleanedDate: lastCleanedDate,
        matrixRunouts: List.unmodifiable(matrixRunouts),
        discStorage: List.unmodifiable(discStorage),
      );
}

String? _text(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
