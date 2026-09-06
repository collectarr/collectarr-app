import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';

class MusicOwnedDetailsDraft extends OwnedDetailsDraft {
  const MusicOwnedDetailsDraft({
    this.storageDevice,
    this.storageSlot,
    this.signedBy,
    this.lastCleanedDate,
    this.matrixRunouts = const [],
  });

  final String? storageDevice;
  final String? storageSlot;
  final String? signedBy;
  final DateTime? lastCleanedDate;
  final List<MusicMatrixRunout> matrixRunouts;

  @override
  MusicOwnedDetails toDetails() => MusicOwnedDetails(
        storageDevice: storageDevice,
        storageSlot: storageSlot,
        signedBy: signedBy,
        lastCleanedDate: lastCleanedDate,
        matrixRunouts: matrixRunouts,
      );
}
