import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:flutter/material.dart';

class LibraryFilterEngine {
  const LibraryFilterEngine({
    this.groupingEngine = const LibraryGroupingEngine(),
  });

  final LibraryGroupingEngine groupingEngine;

  bool matches({
    required LibraryProjectionItem item,
    required LibraryProjectionQuery query,
    required LibrarySearchDocument searchDoc,
    required LibraryKindRuntime type,
    LibraryProjectionIndex? index,
    Set<String> activeLoanOwnedItemIds = const {},
    Map<String, Map<String, String>> customFieldValuesByDefinitionByItem =
        const {},
  }) {
    if (!searchDoc.matches(query.searchQuery)) {
      return false;
    }
    if (query.constrainedItemIds != null &&
        !query.constrainedItemIds!.contains(item.node.id)) {
      return false;
    }
    if (!_matchesBucketScopeFilters(
        item, type, query.bucketScopeFilters, index)) {
      return false;
    }
    if (query.selectedBucket != null &&
        !_matchesBucket(item, type, _defaultGroupId(type, query),
            query.selectedBucket, index)) {
      return false;
    }
    if (!_matchesCollectionStatusScope(item, query.collectionStatusScope)) {
      return false;
    }
    if (!_matchesQuickView(item, query.quickView)) {
      return false;
    }
    if (!_matchesFilter(
      item,
      type,
      query.filterSelection,
      activeLoanOwnedItemIds,
      customFieldValuesByDefinitionByItem,
    )) {
      return false;
    }
    if (!_matchesLinkedMetadata(item, query.linkedMetadataFilter, type)) {
      return false;
    }
    return true;
  }

  bool _matchesBucket(
    LibraryProjectionItem item,
    LibraryKindRuntime type,
    LibraryGroupIdRuntime groupId,
    String? selectedBucket,
    LibraryProjectionIndex? index,
  ) {
    if (selectedBucket == null) return true;
    final bucket = index != null
        ? index.getGroupBucket(
            item,
            groupId,
            (it, mode) => groupingEngine.getGroupBucketForItem(it, type, mode),
          )
        : groupingEngine.getGroupBucketForItem(item, type, groupId);
    return bucket == selectedBucket;
  }

  bool _matchesBucketScopeFilters(
    LibraryProjectionItem item,
    LibraryKindRuntime type,
    List<LibraryBucketScopeFilter> filters,
    LibraryProjectionIndex? index,
  ) {
    for (final filter in filters) {
      final bucket = index != null
          ? index.getGroupBucket(
              item,
              filter.groupId,
              (it, mode) =>
                  groupingEngine.getGroupBucketForItem(it, type, mode),
            )
          : groupingEngine.getGroupBucketForItem(item, type, filter.groupId);
      if (bucket != filter.bucket) {
        return false;
      }
    }
    return true;
  }

  LibraryGroupIdRuntime _defaultGroupId(
    LibraryKindRuntime type,
    LibraryProjectionQuery query,
  ) {
    final fields = type.fields;
    return query.groupId ?? fields.defaultGroup ?? fields.groups.first.id;
  }

  bool _matchesCollectionStatusScope(
    LibraryProjectionItem item,
    LibraryCollectionStatusScope scope,
  ) {
    final ownedItem = item.source.ownedItem;
    final isSold = ownedItem?.isSold == true;
    final collectionStatus =
        item.source.ownedItem?.collectionStatus?.trim().toLowerCase();
    final isWishlistOnly = item.source.isWishlisted && !item.source.isOwned;
    final isCatalogOnly = !item.source.isOwned && !item.source.isWishlisted;
    final isForSale = !isSold && collectionStatus == 'for_sale';
    final isOnOrder = !isSold && collectionStatus == 'on_order';
    final isInCollection =
        item.source.isOwned && !isSold && !isForSale && !isOnOrder;

    return switch (scope) {
      LibraryCollectionStatusScope.all => true,
      LibraryCollectionStatusScope.inCollection => isInCollection,
      LibraryCollectionStatusScope.forSale => isForSale,
      LibraryCollectionStatusScope.wishList => isWishlistOnly,
      LibraryCollectionStatusScope.onOrder => isOnOrder,
      LibraryCollectionStatusScope.sold => isSold,
      LibraryCollectionStatusScope.notInCollection => isCatalogOnly,
    };
  }

  bool _matchesQuickView(
    LibraryProjectionItem item,
    LibraryQuickView? quickView,
  ) {
    return switch (quickView) {
      null => true,
      LibraryQuickView.owned => item.source.isOwned,
      LibraryQuickView.wishlist => item.source.isWishlisted,
      LibraryQuickView.missingCovers =>
        item.dto.coverImageUrl == null || item.dto.coverImageUrl!.isEmpty,
      LibraryQuickView.missingMetadata => false,
      LibraryQuickView.missingGrade => item.source.isOwned &&
          (item.source.grade == null || item.source.grade!.trim().isEmpty),
    };
  }

  bool _matchesFilter(
    LibraryProjectionItem item,
    LibraryKindRuntime type,
    LibraryFilterSelection filters,
    Set<String> activeLoanOwnedItemIds,
    Map<String, Map<String, String>> customFieldValuesByDefinitionByItem,
  ) {
    if (!filters.hasActiveFilters) {
      return true;
    }
    if (!libraryFilterMatches(
      item,
      filters,
      filterDefinitions: type.presentation.filterDefinitions,
    )) {
      return false;
    }
    if (!libraryTrackingStatusMatchesFilter(
      item.source.tracking.status,
      filters.trackingStatusFilter,
    )) {
      return false;
    }
    if (!_matchesLoanFilter(
        item, filters.loanStatusFilter, activeLoanOwnedItemIds)) {
      return false;
    }
    if (!_matchesDateRange(item, filters)) {
      return false;
    }
    if (!_matchesCustomField(
      item,
      filters,
      customFieldValuesByDefinitionByItem,
    )) {
      return false;
    }
    return true;
  }

  bool _matchesCustomField(
    LibraryProjectionItem item,
    LibraryFilterSelection filters,
    Map<String, Map<String, String>> customFieldValuesByDefinitionByItem,
  ) {
    final definitionId = filters.customFieldDefinitionId;
    if (definitionId == null || definitionId.isEmpty) {
      return true;
    }
    final ownedItemId = item.source.ownedItem?.id;
    if (ownedItemId == null) {
      return false;
    }
    final values = customFieldValuesByDefinitionByItem[ownedItemId];
    final actualValue = values?[definitionId]?.trim();
    if (actualValue == null || actualValue.isEmpty) {
      return false;
    }
    final expectedValue = filters.customFieldValue?.trim();
    if (expectedValue == null || expectedValue.isEmpty) {
      return true;
    }
    final parsedValues = parseCustomFieldMultiValues(actualValue);
    if (parsedValues.isNotEmpty) {
      return parsedValues.contains(expectedValue);
    }
    return actualValue == expectedValue;
  }

  bool _matchesLoanFilter(
    LibraryProjectionItem item,
    LibraryLoanStatusFilter filter,
    Set<String> activeLoanOwnedItemIds,
  ) {
    if (filter == LibraryLoanStatusFilter.all) {
      return true;
    }
    final ownedItemId = item.source.ownedItem?.id;
    if (ownedItemId == null) {
      return false;
    }
    final hasActiveLoan = activeLoanOwnedItemIds.contains(ownedItemId);
    return switch (filter) {
      LibraryLoanStatusFilter.all => true,
      LibraryLoanStatusFilter.onLoan => hasActiveLoan,
      LibraryLoanStatusFilter.available => !hasActiveLoan,
    };
  }

  bool _matchesDateRange(
    LibraryProjectionItem item,
    LibraryFilterSelection filters,
  ) {
    if (!filters.hasActiveDateRange) {
      return true;
    }
    final value = _filterDateForItem(item, filters.dateRangeField);
    if (value == null) {
      return false;
    }
    final candidate = DateUtils.dateOnly(value.toLocal());
    final from = filters.dateFrom == null
        ? null
        : DateUtils.dateOnly(filters.dateFrom!.toLocal());
    final to = filters.dateTo == null
        ? null
        : DateUtils.dateOnly(filters.dateTo!.toLocal());
    if (from != null && candidate.isBefore(from)) {
      return false;
    }
    if (to != null && candidate.isAfter(to)) {
      return false;
    }
    return true;
  }

  DateTime? _filterDateForItem(
    LibraryProjectionItem item,
    LibraryDateRangeField field,
  ) {
    final ownedItem = item.source.ownedItem;
    final trackingEntry = item.source.trackingEntry;
    return switch (field) {
      LibraryDateRangeField.updated => item.source.updatedAt,
      LibraryDateRangeField.purchased => ownedItem?.purchaseDate,
      LibraryDateRangeField.started =>
        trackingEntry?.startedAt ?? ownedItem?.startedAt,
      LibraryDateRangeField.finished =>
        trackingEntry?.finishedAt ?? ownedItem?.finishedAt,
    };
  }

  bool _matchesLinkedMetadata(
    LibraryProjectionItem item,
    LibraryLinkedMetadataFilter? linkedMetadataFilter,
    LibraryKindRuntime type,
  ) {
    if (linkedMetadataFilter == null) {
      return true;
    }
    final normalized = linkedMetadataFilter.value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return true;
    }
    for (final candidate
        in type.linkedMetadata.candidatesForEntry(item.source)) {
      if (candidate.trim().toLowerCase() == normalized) {
        return true;
      }
    }
    return false;
  }
}
