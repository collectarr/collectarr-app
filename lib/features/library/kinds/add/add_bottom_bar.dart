import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog_theme.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

ButtonStyle _kindOutlinedButtonStyle(Color accent) {
  return OutlinedButton.styleFrom(
    foregroundColor: accent,
    side: BorderSide(color: accent.withValues(alpha: 0.35)),
    minimumSize: const Size(0, 36),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    textStyle: const TextStyle(fontWeight: FontWeight.w800),
  );
}

Widget buildKindAddBottomBar(
  BuildContext context,
  LibraryAddBottomBarRequest request,
) {
  final palette = appPalette(context);
  final hasSelection = request.selectedItem != null || request.selectedCandidate != null;
  final effectiveCount = request.addCount > 0 ? request.addCount : (hasSelection ? 1 : 0);
  final primaryLabel = _primaryAddLabel(request, effectiveCount);
  return DecoratedBox(
    decoration: BoxDecoration(
      color: palette.panel,
      border: Border(top: BorderSide(color: palette.divider)),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<LibraryAddTarget>(
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      side: WidgetStatePropertyAll(
                        BorderSide(color: request.accent.withValues(alpha: 0.32)),
                      ),
                    ),
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment<LibraryAddTarget>(
                        value: LibraryAddTarget.owned,
                        label: Text('Collection'),
                        icon: Icon(Icons.library_add_outlined, size: 18),
                      ),
                      ButtonSegment<LibraryAddTarget>(
                        value: LibraryAddTarget.wishlist,
                        label: Text('Wishlist'),
                        icon: Icon(Icons.favorite_border, size: 18),
                      ),
                      ButtonSegment<LibraryAddTarget>(
                        value: LibraryAddTarget.track,
                        label: Text('Track'),
                        icon: Icon(Icons.visibility_outlined, size: 18),
                      ),
                    ],
                    selected: {request.addTarget},
                    onSelectionChanged: request.isAdding
                        ? null
                        : (selection) {
                            if (selection.isNotEmpty) {
                              request.onAddTargetChanged(selection.first);
                            }
                          },
                  ),
                ),
              ),
              if (request.isAdmin && request.selectedCandidate != null) ...[
                const SizedBox(width: 8),
                _AdminOverflowMenu(request: request),
              ],
            ],
          ),
          if (request.addTarget == LibraryAddTarget.owned) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<String>(
                    initialValue: request.defaultCondition,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Condition',
                      isDense: true,
                    ),
                    items: [
                      for (final value in request.conditions)
                        DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                    ],
                    onChanged: request.isAdding
                        ? null
                        : (value) {
                            if (value != null) {
                              request.onDefaultConditionChanged(value);
                            }
                          },
                  ),
                ),
                SizedBox(
                  width: 130,
                  child: DropdownButtonFormField<String>(
                    initialValue: request.defaultGrade,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Grade',
                      isDense: true,
                    ),
                    items: [
                      for (final value in request.grades)
                        DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                    ],
                    onChanged: request.isAdding
                        ? null
                        : (value) {
                            if (value != null) {
                              request.onDefaultGradeChanged(value);
                            }
                          },
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: request.isAdding ? null : request.onDefaultLocationPressed,
                  style: _kindOutlinedButtonStyle(request.accent),
                  icon: const Icon(Icons.place_outlined, size: 16),
                  label: Text(request.defaultLocationLabel ?? 'Location'),
                ),
                OutlinedButton.icon(
                  onPressed: request.isAdding
                      ? null
                      : () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: request.defaultPurchaseDate ?? now,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(now.year + 3, 12, 31),
                          );
                          if (picked != null) {
                            request.onDefaultPurchaseDateChanged(picked);
                          }
                        },
                  style: _kindOutlinedButtonStyle(request.accent),
                  icon: const Icon(Icons.event_outlined, size: 16),
                  label: Text(_purchaseDateLabel(request.defaultPurchaseDate)),
                ),
                OutlinedButton.icon(
                  onPressed: request.isAdding ? null : request.onEditDefaultTagsPressed,
                  style: _kindOutlinedButtonStyle(request.accent),
                  icon: const Icon(Icons.sell_outlined, size: 16),
                  label: Text(
                    request.defaultTags?.trim().isNotEmpty == true
                        ? 'Tags: ${request.defaultTags!}'
                        : 'Tags',
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: request.isAdding ? null : request.onAdd,
                  style: libraryAddFilledButtonStyle(request.accent),
                  child: request.isAdding
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(primaryLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

String _primaryAddLabel(LibraryAddBottomBarRequest request, int count) {
  if (request.selectedCandidate != null) {
    return switch (request.addTarget) {
      LibraryAddTarget.owned => 'Add to Collection',
      LibraryAddTarget.wishlist => 'Add to Wishlist',
      LibraryAddTarget.track => 'Track in Library',
    };
  }
  if (count <= 0) {
    return switch (request.addTarget) {
      LibraryAddTarget.owned => 'Select items to add',
      LibraryAddTarget.wishlist => 'Select items for wishlist',
      LibraryAddTarget.track => 'Select items to track',
    };
  }
  if (count == 1) {
    return switch (request.addTarget) {
      LibraryAddTarget.owned => 'Add to Collection',
      LibraryAddTarget.wishlist => 'Add to Wishlist',
      LibraryAddTarget.track => 'Track in Library',
    };
  }
  return switch (request.addTarget) {
    LibraryAddTarget.owned => 'Add $count to Collection',
    LibraryAddTarget.wishlist => 'Add $count to Wishlist',
    LibraryAddTarget.track => 'Track $count in Library',
  };
}

String _purchaseDateLabel(DateTime? date) {
  if (date == null) {
    return 'Purchase date';
  }
  final month = switch (date.month) {
    1 => 'Jan',
    2 => 'Feb',
    3 => 'Mar',
    4 => 'Apr',
    5 => 'May',
    6 => 'Jun',
    7 => 'Jul',
    8 => 'Aug',
    9 => 'Sep',
    10 => 'Oct',
    11 => 'Nov',
    _ => 'Dec',
  };
  return '$month ${date.day}, ${date.year}';
}

enum _AdminAction { queueIngest, propose }

class _AdminOverflowMenu extends StatelessWidget {
  const _AdminOverflowMenu({required this.request});

  final LibraryAddBottomBarRequest request;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_AdminAction>(
      tooltip: 'More actions',
      enabled: request.onQueueIngest != null || request.onPropose != null,
      onSelected: (action) {
        switch (action) {
          case _AdminAction.queueIngest:
            request.onQueueIngest?.call();
          case _AdminAction.propose:
            request.onPropose?.call();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<_AdminAction>(
          value: _AdminAction.queueIngest,
          enabled: request.selectedQueuedIngest == null && request.onQueueIngest != null,
          child: Text(
            request.selectedQueuedIngest == null ? 'Queue ingest' : 'Ingest queued',
          ),
        ),
        PopupMenuItem<_AdminAction>(
          value: _AdminAction.propose,
          enabled: request.onPropose != null,
          child: const Text('Propose metadata'),
        ),
      ],
      child: OutlinedButton.icon(
        onPressed: null,
        style: _kindOutlinedButtonStyle(request.accent),
        icon: const Icon(Icons.more_horiz, size: 18),
        label: const Text('More'),
      ),
    );
  }
}