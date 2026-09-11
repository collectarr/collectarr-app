import 'package:flutter/material.dart';

import 'catalog_entity_ref.dart';
import 'owned_item_projection.dart';

/// The category of a calendar event.
enum CalendarEventKind {
  releaseDate,
  loanDue,
  loanReturn,
  purchased,
  started,
  finished,
  watched,
}

/// A single calendar event derived from existing collection data.
class CalendarEvent {
  const CalendarEvent({
    required this.kind,
    required this.date,
    required this.title,
    this.eventId,
    this.subtitle,
    this.catalogRef,
    this.ownedRef,
  });

  final CalendarEventKind kind;
  final DateTime date;
  final String title;

  /// Stable identity for synchronization/export.
  final String? eventId;
  final String? subtitle;

  /// Structural catalog target, if applicable.
  final CatalogEntityRef? catalogRef;

  /// Structural owned-copy target, if applicable (for loans, purchases).
  final OwnedItemRef? ownedRef;

  String get label => switch (kind) {
        CalendarEventKind.releaseDate => 'Release',
        CalendarEventKind.loanDue => 'Loan due',
        CalendarEventKind.loanReturn => 'Returned',
        CalendarEventKind.purchased => 'Purchased',
        CalendarEventKind.started => 'Started',
        CalendarEventKind.finished => 'Finished',
        CalendarEventKind.watched => 'Watched',
      };

  IconData get icon => switch (kind) {
        CalendarEventKind.releaseDate => Icons.new_releases_outlined,
        CalendarEventKind.loanDue => Icons.event_outlined,
        CalendarEventKind.loanReturn => Icons.assignment_return_outlined,
        CalendarEventKind.purchased => Icons.shopping_cart_outlined,
        CalendarEventKind.started => Icons.play_arrow_outlined,
        CalendarEventKind.finished => Icons.check_circle_outline,
        CalendarEventKind.watched => Icons.visibility_outlined,
      };

  Color color(Color accent) => switch (kind) {
        CalendarEventKind.releaseDate => Colors.blue,
        CalendarEventKind.loanDue => Colors.orange,
        CalendarEventKind.loanReturn => Colors.green,
        CalendarEventKind.purchased => accent,
        CalendarEventKind.started => Colors.teal,
        CalendarEventKind.finished => Colors.green,
        CalendarEventKind.watched => Colors.purple,
      };
}
