import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_disc_storage.dart';

class MusicOwnedDetailsDraft implements JsonEncodable {
  const MusicOwnedDetailsDraft({
    this.storageDevice,
    this.storageSlot,
    this.signedBy,
    this.lastCleanedDate,
    this.matrixRunouts = const [],
    this.discStorage = const [],
  });

  final String? storageDevice;
  final String? storageSlot;
  final String? signedBy;
  final DateTime? lastCleanedDate;
  final List<MusicMatrixRunout> matrixRunouts;
  final List<MusicDiscStorage> discStorage;

  MusicOwnedDetails toDetails() => MusicOwnedDetails(
        storageDevice: storageDevice,
        storageSlot: storageSlot,
        signedBy: signedBy,
        lastCleanedDate: lastCleanedDate,
        matrixRunouts: matrixRunouts,
        discStorage: discStorage,
      );

  @override
  Map<String, dynamic> toJson() => toDetails().toJson();
}
