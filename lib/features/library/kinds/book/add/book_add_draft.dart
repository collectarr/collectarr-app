import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/signature_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_draft.dart';
import 'package:flutter/foundation.dart';

@immutable
final class BookAddDraft extends LibraryAddKindDraft {
  const BookAddDraft({
    this.signature = const SignatureDraft(),
    String? signedBy,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
  }) : _signedBy = signedBy;

  final SignatureDraft signature;
  final String? _signedBy;
  final bool dustJacketPresent;
  final String? dustJacketCondition;

  String? get signedBy => _signedBy ?? signature.signedBy;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  OwnedDetailsDraft toOwnedDetailsDraft() => BookOwnedDetailsDraft(
        signedBy: signedBy,
        dustJacketPresent: dustJacketPresent,
        dustJacketCondition: dustJacketCondition,
      );
}
