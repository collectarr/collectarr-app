import 'dart:convert';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefillDefaults {
  static const _locationKey = 'collectarr.prefill.location_id';
  static const _tagsKey = 'collectarr.prefill.tag_list';

  const PrefillDefaults(
      {this.locationId,
      this.tags,
      this.personalValues = const {},
      this.alwaysShow = true,
      this.fillPurchaseDateWithToday = false});
  final String? locationId;
  final List<String>? tags;
  final Map<String, dynamic> personalValues;
  final bool alwaysShow;
  final bool fillPurchaseDateWithToday;

  static Future<PrefillDefaults> load([CatalogMediaKind? kind]) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = kind == null
        ? null
        : prefs.getString('collectarr.prefill.${kind.apiValue}.personal');
    return PrefillDefaults(
        alwaysShow: prefs.getBool(
                'collectarr.prefill.${kind?.apiValue ?? 'all'}.always_show') ??
            true,
        fillPurchaseDateWithToday: prefs.getBool(
                'collectarr.prefill.${kind?.apiValue ?? 'all'}.purchase_today') ??
            false,
        locationId: prefs.getString(_locationKey),
        tags: prefs.getStringList(_tagsKey),
        personalValues: raw == null
            ? const {}
            : Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  Future<void> save([CatalogMediaKind? kind]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'collectarr.prefill.${kind?.apiValue ?? 'all'}.always_show',
        alwaysShow);
    await prefs.setBool(
        'collectarr.prefill.${kind?.apiValue ?? 'all'}.purchase_today',
        fillPurchaseDateWithToday);
    if (locationId == null || locationId!.isEmpty) {
      await prefs.remove(_locationKey);
    } else {
      await prefs.setString(_locationKey, locationId!);
    }
    if (tags == null || tags!.isEmpty) {
      await prefs.remove(_tagsKey);
    } else {
      await prefs.setStringList(_tagsKey, tags!);
    }
    if (kind != null) {
      await prefs.setString('collectarr.prefill.${kind.apiValue}.personal',
          jsonEncode(personalValues));
    }
  }

  LibraryAddCommonDraft applyTo(LibraryAddCommonDraft draft) => draft.copyWith(
        condition: draft.condition ?? personalValues['condition'] as String?,
        purchaseDate: draft.purchaseDate ??
            (fillPurchaseDateWithToday ? DateTime.now() : null) ??
            PartialDate.tryParse(personalValues['purchase_date_parts'])
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
