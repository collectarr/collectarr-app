import 'dart:convert';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefillDefaults {
  const PrefillDefaults(
      {this.locationId, this.tags, this.personalValues = const {}});
  final String? locationId;
  final String? tags;
  final Map<String, dynamic> personalValues;

  static Future<PrefillDefaults> load([CatalogMediaKind? kind]) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = kind == null
        ? null
        : prefs.getString('collectarr.prefill.${kind.apiValue}.personal');
    return PrefillDefaults(
        locationId: prefs.getString('collectarr.prefill.location_id'),
        tags: prefs.getString('collectarr.prefill.tags'),
        personalValues: raw == null
            ? const {}
            : Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  Future<void> save([CatalogMediaKind? kind]) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in {'location_id': locationId, 'tags': tags}.entries) {
      if (entry.value == null || entry.value!.isEmpty) {
        await prefs.remove('collectarr.prefill.${entry.key}');
      } else {
        await prefs.setString('collectarr.prefill.${entry.key}', entry.value!);
      }
    }
    if (kind != null) {
      await prefs.setString('collectarr.prefill.${kind.apiValue}.personal',
          jsonEncode(personalValues));
    }
  }

  LibraryAddCommonDraft applyTo(LibraryAddCommonDraft draft) => draft.copyWith(
        condition: draft.condition ?? personalValues['condition'] as String?,
        purchaseDate: draft.purchaseDate ??
            PartialDate.tryParse(personalValues['purchase_date_parts'] ??
                    personalValues['purchase_date'])
                ?.asDateTime,
        pricePaidCents: draft.pricePaidCents ??
            (personalValues['price_paid_cents'] as num?)?.toInt(),
        currency: draft.currency ?? personalValues['currency'] as String?,
        personalNotes:
            draft.personalNotes ?? personalValues['personal_notes'] as String?,
        tags: draft.tags ?? tags,
        locationId: draft.clearLocation ? null : draft.locationId ?? locationId,
        purchaseStore:
            draft.purchaseStore ?? personalValues['purchase_store'] as String?,
        ownerLabel:
            draft.ownerLabel ?? personalValues['owner_label'] as String?,
        collectionStatus: draft.collectionStatus ??
            personalValues['collection_status'] as String?,
        isDigital: draft.isDigital ?? personalValues['is_digital'] as bool?,
      );
}
