import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';

class ComicOwnedDetailsDraft implements JsonEncodable {
  const ComicOwnedDetailsDraft({
    this.rawOrSlabbed,
    this.gradingCompany,
    this.graderNotes,
    this.signedBy,
    this.labelType,
    this.customLabel,
    this.pageQuality,
    this.certificationNumber,
    this.keyComic = false,
    this.keyReason,
    this.keyCategory,
    this.keySeverity,
    this.coverPriceCents,
    this.lastBagBoardDate,
  });

  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? signedBy;
  final String? labelType;
  final String? customLabel;
  final String? pageQuality;
  final String? certificationNumber;
  final bool keyComic;
  final String? keyReason;
  final String? keyCategory;
  final String? keySeverity;
  final int? coverPriceCents;
  final DateTime? lastBagBoardDate;

  ComicOwnedDetails toDetails() => ComicOwnedDetails(
        rawOrSlabbed: rawOrSlabbed,
        gradingCompany: gradingCompany,
        graderNotes: graderNotes,
        signedBy: signedBy,
        labelType: labelType,
        customLabel: customLabel,
        pageQuality: pageQuality,
        certificationNumber: certificationNumber,
        keyComic: keyComic,
        keyReason: keyReason,
        keyCategory: keyCategory,
        keySeverity: keySeverity,
        coverPriceCents: coverPriceCents,
        lastBagBoardDate: lastBagBoardDate,
      );

  @override
  Map<String, dynamic> toJson() => toDetails().toJson();
}
