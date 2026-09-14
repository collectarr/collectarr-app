import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';

final class MusicOwnedEditDraft {
  MusicOwnedEditDraft.fromDetails(MusicOwnedDetails details)
      : original = details,
        storageDevice = details.storageDevice,
        storageSlot = details.storageSlot,
        signedBy = details.signedBy,
        lastCleanedDate = details.lastCleanedDate,
        matrixRunouts = List<MusicMatrixRunout>.from(details.matrixRunouts);

  final MusicOwnedDetails original;
  String? storageDevice;
  String? storageSlot;
  String? signedBy;
  DateTime? lastCleanedDate;
  List<MusicMatrixRunout> matrixRunouts;

  MusicOwnedDetails toDetails() => MusicOwnedDetails(
        storageDevice: _text(storageDevice),
        storageSlot: _text(storageSlot),
        signedBy: _text(signedBy),
        lastCleanedDate: lastCleanedDate,
        matrixRunouts: List.unmodifiable(matrixRunouts),
      );
}

String? _text(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
