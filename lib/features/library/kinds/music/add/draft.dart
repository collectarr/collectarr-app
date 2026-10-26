import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:flutter/foundation.dart';

@immutable
final class MusicAddDraft extends LibraryAddKindDraft {
  const MusicAddDraft({
    this.grade = 'Ungraded',
    this.initialListens = const [],
    this.quantity = 1,
    this.indexNumber,
    this.rating,
    this.marketValueCents,
    this.mediaCondition,
    this.purchaseDateParts,
    this.lastCleanedDateParts,
    this.media = const [],
    this.signedBy,
  });

  final List<MusicListenEvent> initialListens;
  final String? grade;
  final int quantity;
  final int? indexNumber;
  final int? rating;
  final int? marketValueCents;
  final String? mediaCondition;
  final PartialDate? purchaseDateParts;
  final PartialDate? lastCleanedDateParts;
  final List<MusicEntryDiscDetails> media;
  final String? signedBy;

  MusicAddDraft copyWith({
    Object? grade = _musicAddDraftUnset,
    List<MusicListenEvent>? initialListens,
    int? quantity,
    Object? indexNumber = _musicAddDraftUnset,
    Object? rating = _musicAddDraftUnset,
    Object? marketValueCents = _musicAddDraftUnset,
    Object? mediaCondition = _musicAddDraftUnset,
    Object? purchaseDateParts = _musicAddDraftUnset,
    Object? lastCleanedDateParts = _musicAddDraftUnset,
    List<MusicEntryDiscDetails>? media,
    Object? signedBy = _musicAddDraftUnset,
  }) =>
      MusicAddDraft(
        initialListens: initialListens ?? this.initialListens,
        quantity: quantity ?? this.quantity,
        indexNumber: identical(indexNumber, _musicAddDraftUnset)
            ? this.indexNumber
            : indexNumber as int?,
        rating: identical(rating, _musicAddDraftUnset)
            ? this.rating
            : rating as int?,
        marketValueCents: identical(marketValueCents, _musicAddDraftUnset)
            ? this.marketValueCents
            : marketValueCents as int?,
        mediaCondition: identical(mediaCondition, _musicAddDraftUnset)
            ? this.mediaCondition
            : mediaCondition as String?,
        purchaseDateParts: identical(purchaseDateParts, _musicAddDraftUnset)
            ? this.purchaseDateParts
            : purchaseDateParts as PartialDate?,
        lastCleanedDateParts:
            identical(lastCleanedDateParts, _musicAddDraftUnset)
                ? this.lastCleanedDateParts
                : lastCleanedDateParts as PartialDate?,
        grade: identical(grade, _musicAddDraftUnset)
            ? this.grade
            : grade as String?,
        media: media ?? this.media,
        signedBy: identical(signedBy, _musicAddDraftUnset)
            ? this.signedBy
            : signedBy as String?,
      );

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  JsonEncodable toEntryDetailsDraft() => MusicEntryDetailsDraft(
        media: media,
        signedBy: signedBy,
        lastCleanedDate: lastCleanedDateParts?.asDateTime,
        lastCleanedDateParts: lastCleanedDateParts,
      );
}

const Object _musicAddDraftUnset = Object();
