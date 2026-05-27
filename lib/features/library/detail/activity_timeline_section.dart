import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/library/detail/activity_event_aggregator.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Collapsible activity timeline section shown on the detail page.
class ActivityTimelineSection extends ConsumerStatefulWidget {
  const ActivityTimelineSection({
    super.key,
    required this.itemId,
    required this.ownedItemIds,
    required this.accent,
  });

  final String itemId;

  /// All owned-item IDs for this catalog item (needed for loan lookup).
  final List<String> ownedItemIds;
  final Color accent;

  @override
  ConsumerState<ActivityTimelineSection> createState() =>
      _ActivityTimelineSectionState();
}

class _ActivityTimelineSectionState
    extends ConsumerState<ActivityTimelineSection> {
  List<Loan>? _loans;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  @override
  void didUpdateWidget(covariant ActivityTimelineSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemId != oldWidget.itemId) {
      _loans = null;
      _loadLoans();
    }
  }

  Future<void> _loadLoans() async {
    final db = ref.read(localDatabaseProvider);
    final repo = LoanRepository(db);
    final allLoans = <Loan>[];
    for (final ownedItemId in widget.ownedItemIds) {
      allLoans.addAll(await repo.getLoansForItem(ownedItemId));
    }
    if (mounted) setState(() => _loans = allLoans);
  }

  @override
  Widget build(BuildContext context) {
    final ownedItems = ref.watch(collectionProvider).maybeWhen(
          data: (items) =>
              items.where((i) => i.itemId == widget.itemId).toList(),
          orElse: () => const <OwnedItem>[],
        );
    final trackingEntries =
        ref.watch(trackingEntriesByCatalogItemProvider)[widget.itemId] ??
            const <TrackingEntry>[];
    final watchSessions =
        ref.watch(watchSessionsByItemProvider)[widget.itemId] ??
            const <WatchSession>[];
    final wishlistItems =
        ref.watch(wishlistByCatalogItemProvider)[widget.itemId] ??
            const <WishlistItem>[];

    final events = ActivityEventAggregator.aggregate(
      ownedItems: ownedItems,
      trackingEntries: trackingEntries,
      watchSessions: watchSessions,
      wishlistItems: wishlistItems,
      loans: _loans ?? const [],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: appPalette(context).surfaceSubtle,
        border: Border.all(color: widget.accent.withValues(alpha: 0.33)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: widget.accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
            ),
            if (events.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'No activity recorded yet.',
                  style: TextStyle(color: kAppTextMuted, fontSize: 12),
                ),
              )
            else ...[
              const SizedBox(height: 8),
              for (var i = 0; i < events.length; i++)
                _ActivityEventTile(
                  event: events[i],
                  accent: widget.accent,
                  isLast: i == events.length - 1,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActivityEventTile extends StatelessWidget {
  const _ActivityEventTile({
    required this.event,
    required this.accent,
    this.isLast = false,
  });

  final ActivityEvent event;
  final Color accent;
  final bool isLast;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _fmtDate(DateTime dt) {
    final l = dt.toLocal();
    return '${_months[l.month - 1]} ${l.day}, ${l.year}';
  }

  static String _fmtTime(DateTime dt) {
    final l = dt.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.18),
                    border: Border.all(color: accent.withValues(alpha: 0.5)),
                  ),
                  child: Icon(event.icon, size: 12, color: accent),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: accent.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_fmtDate(event.timestamp)} · ${_fmtTime(event.timestamp)}',
                    style: const TextStyle(
                      color: kAppTextMuted,
                      fontSize: 11,
                    ),
                  ),
                  if (event.detail != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.detail!,
                      style: TextStyle(
                        color: accent.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (event.secondaryDetail != null)
                    Text(
                      event.secondaryDetail!,
                      style: const TextStyle(
                        color: kAppTextMuted,
                        fontSize: 11,
                      ),
                    ),
                  if (event.rating != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < event.rating! ? Icons.star : Icons.star_border,
                            size: 14,
                            color: i < event.rating!
                                ? Colors.amber
                                : kAppTextMuted,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
