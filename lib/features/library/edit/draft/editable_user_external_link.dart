import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class EditableUserExternalLink {
  EditableUserExternalLink({
    required this.labelController,
    required this.urlController,
    required this.kind,
    this.id,
    required this.catalogRef,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory EditableUserExternalLink.fromUserExternalLink(UserExternalLink link) {
    return EditableUserExternalLink(
      id: link.id,
      labelController: TextEditingController(text: link.label),
      urlController: TextEditingController(text: link.url),
      kind: link.kind,
      catalogRef: link.catalogRef,
      createdAt: link.createdAt,
      updatedAt: link.updatedAt,
    );
  }

  factory EditableUserExternalLink.fromTrailerLink(
    TrailerLinkDto link, {
    required CatalogEntityRef catalogRef,
    String kind = 'trailer',
  }) {
    return EditableUserExternalLink(
      labelController: TextEditingController(text: link.title ?? ''),
      urlController: TextEditingController(text: link.url),
      kind: kind,
      catalogRef: catalogRef,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  final String? id;
  final TextEditingController labelController;
  final TextEditingController urlController;
  String kind;
  final CatalogEntityRef catalogRef;
  final DateTime createdAt;
  DateTime updatedAt;

  UserExternalLink? toUserExternalLink() {
    final url = urlController.text.trim();
    if (url.isEmpty) {
      return null;
    }
    final label = labelController.text.trim();
    return UserExternalLink(
      id: id ?? const Uuid().v4(),
      catalogRef: catalogRef,
      label: label.isEmpty ? url : label,
      url: url,
      kind: kind.trim().isEmpty ? 'custom' : kind.trim(),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  void dispose() {
    labelController.dispose();
    urlController.dispose();
  }
}
