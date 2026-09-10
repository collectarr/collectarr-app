import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';

class MusicOwnedDetailsDraft implements JsonEncodable {
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

  MusicOwnedDetails toDetails() => MusicOwnedDetails(
        storageDevice: storageDevice,
        storageSlot: storageSlot,
        signedBy: signedBy,
        lastCleanedDate: lastCleanedDate,
        matrixRunouts: matrixRunouts,
      );

  @override
  Map<String, dynamic> toJson() => toDetails().toJson();
}
