import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';

Future<void> seedCustomFields(CustomFieldRepository repo) async {
  final now = DateTime.now().toUtc();

  // Definitions
  final defs = [
    CustomFieldDefinition(
      id: 'seed-cf-def-01',
      name: 'Acquisition Source',
      fieldType: 'singleSelect',
      sortOrder: 1,
      options: '["Gift","Purchase","Trade","Found","Inherited"]',
      createdAt: now,
    ),
    CustomFieldDefinition(
      id: 'seed-cf-def-02',
      name: 'Personal Rating Notes',
      fieldType: 'longText',
      sortOrder: 2,
      createdAt: now,
    ),
    CustomFieldDefinition(
      id: 'seed-cf-def-03',
      name: 'Insurance Value',
      fieldType: 'currency',
      sortOrder: 3,
      createdAt: now,
    ),
    CustomFieldDefinition(
      id: 'seed-cf-def-04',
      name: 'Date Cataloged',
      fieldType: 'date',
      sortOrder: 4,
      createdAt: now,
    ),
    CustomFieldDefinition(
      id: 'seed-cf-def-05',
      name: 'Lent Out',
      fieldType: 'boolean',
      sortOrder: 5,
      createdAt: now,
    ),
    CustomFieldDefinition(
      id: 'seed-cf-def-06',
      name: 'Reading Time',
      fieldType: 'time',
      sortOrder: 6,
      createdAt: now,
    ),
    CustomFieldDefinition(
      id: 'seed-cf-def-07',
      name: 'Reference URL',
      fieldType: 'url',
      sortOrder: 7,
      createdAt: now,
    ),
    CustomFieldDefinition(
      id: 'seed-cf-def-08',
      name: 'Contact Person',
      fieldType: 'person',
      sortOrder: 8,
      createdAt: now,
    ),
    CustomFieldDefinition(
      id: 'seed-cf-def-09',
      name: 'Favorite Formats',
      fieldType: 'multiSelect',
      sortOrder: 9,
      options: '["Hardcover","Paperback","Digital","Deluxe"]',
      createdAt: now,
    ),
  ];

  for (final def in defs) {
    await repo.upsertDefinition(def);
  }

  // Values for some owned items
  final values = [
    CustomFieldValue(
      id: 'seed-cf-val-01',
      targetId: 'seed-owned-seed-comic-01',
      targetScope: CustomFieldTargetScope.ownedCopy,
      fieldDefinitionId: 'seed-cf-def-01',
      value: 'Purchase',
      updatedAt: now,
    ),
    CustomFieldValue(
      id: 'seed-cf-val-02',
      targetId: 'seed-owned-seed-comic-01',
      targetScope: CustomFieldTargetScope.ownedCopy,
      fieldDefinitionId: 'seed-cf-def-02',
      value: 'First print, great condition for the price',
      updatedAt: now,
    ),
    CustomFieldValue(
      id: 'seed-cf-val-03',
      targetId: 'seed-owned-seed-comic-03',
      targetScope: CustomFieldTargetScope.ownedCopy,
      fieldDefinitionId: 'seed-cf-def-03',
      value: '350',
      updatedAt: now,
    ),
    CustomFieldValue(
      id: 'seed-cf-val-04',
      targetId: 'seed-owned-seed-book-01',
      targetScope: CustomFieldTargetScope.ownedCopy,
      fieldDefinitionId: 'seed-cf-def-04',
      value: '2020-03-16',
      updatedAt: now,
    ),
    CustomFieldValue(
      id: 'seed-cf-val-05',
      targetId: 'seed-owned-seed-book-07',
      targetScope: CustomFieldTargetScope.ownedCopy,
      fieldDefinitionId: 'seed-cf-def-05',
      value: 'true',
      updatedAt: now,
    ),
    CustomFieldValue(
      id: 'seed-cf-val-06',
      targetId: 'seed-owned-seed-book-01',
      targetScope: CustomFieldTargetScope.ownedCopy,
      fieldDefinitionId: 'seed-cf-def-06',
      value: '20:30',
      updatedAt: now,
    ),
    CustomFieldValue(
      id: 'seed-cf-val-07',
      targetId: 'seed-owned-seed-book-01',
      targetScope: CustomFieldTargetScope.ownedCopy,
      fieldDefinitionId: 'seed-cf-def-07',
      value: 'https://example.com/book-01',
      updatedAt: now,
    ),
    CustomFieldValue(
      id: 'seed-cf-val-08',
      targetId: 'seed-owned-seed-book-07',
      targetScope: CustomFieldTargetScope.ownedCopy,
      fieldDefinitionId: 'seed-cf-def-08',
      value: 'Jane Doe',
      updatedAt: now,
    ),
    CustomFieldValue(
      id: 'seed-cf-val-09',
      targetId: 'seed-owned-seed-book-07',
      targetScope: CustomFieldTargetScope.ownedCopy,
      fieldDefinitionId: 'seed-cf-def-09',
      value: '["Hardcover","Digital"]',
      updatedAt: now,
    ),
  ];

  await repo.upsertValues(values);
}
