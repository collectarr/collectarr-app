import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:xml/xml.dart';

/// Serializes and deserializes ComicInfo.xml (ComicRack/Kavita/Komga standard).
class ComicInfoXml {
  const ComicInfoXml();

  /// Build a ComicInfo.xml string from catalog + owned data.
  String serialize(LibraryMetadataItem catalog, [OwnedItem? owned]) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="utf-8"');
    builder.element('ComicInfo', nest: () {
      builder.attribute(
        'xmlns:xsi',
        'http://www.w3.org/2001/XMLSchema-instance',
      );
      builder.attribute(
        'xmlns:xsd',
        'http://www.w3.org/2001/XMLSchema',
      );

      _optionalElement(builder, 'Title', catalog.title);
      _optionalElement(
        builder,
        'Series',
        catalog.series?.seriesTitle ?? catalog.title,
      );
      _optionalElement(builder, 'Number', catalog.itemNumber);
      if (catalog.series?.volumeNumber != null) {
        _optionalElement(
          builder,
          'Volume',
          catalog.series!.volumeNumber.toString(),
        );
      }
      _optionalElement(builder, 'Summary', catalog.synopsis);
      if (catalog.releaseDate != null) {
        _optionalElement(builder, 'Year', catalog.releaseDate!.year.toString());
        _optionalElement(
            builder, 'Month', catalog.releaseDate!.month.toString());
        _optionalElement(builder, 'Day', catalog.releaseDate!.day.toString());
      } else if (catalog.releaseYear != null) {
        _optionalElement(builder, 'Year', catalog.releaseYear.toString());
      }
      _optionalElement(builder, 'Publisher', catalog.publisher);
      _optionalElement(builder, 'Format', catalog.physicalFormatLabel);

      // Collection-specific fields from OwnedItem
      if (owned != null) {
        _optionalElement(builder, 'Notes', owned.personalNotes);
        if (owned.rating != null && owned.rating! > 0) {
          // ComicInfo uses 0-5 scale; our rating is 0-10, map accordingly
          final comicInfoRating = (owned.rating! / 2).round().clamp(0, 5);
          _optionalElement(
              builder, 'CommunityRating', comicInfoRating.toStringAsFixed(1));
        }
        if (owned.tags != null && owned.tags!.trim().isNotEmpty) {
          _optionalElement(builder, 'Tags', owned.tags);
        }
      }
    });
    return builder.buildDocument().toXmlString(pretty: true);
  }

  /// Parse a ComicInfo.xml string into a partial metadata item + notes map.
  ComicInfoData deserialize(String xmlString) {
    final split = splitForImport(xmlString);

    return ComicInfoData(
      title: split.canonical.title,
      seriesTitle: split.canonical.seriesTitle,
      itemNumber: split.canonical.itemNumber,
      volumeNumber: split.canonical.volumeNumber,
      synopsis: split.canonical.synopsis,
      publisher: split.canonical.publisher,
      releaseDate: split.canonical.releaseDate,
      releaseYear: split.canonical.releaseYear,
      physicalFormatLabel: split.canonical.physicalFormatLabel,
      notes: split.personal.notes,
      tags: split.personal.tags,
      rating: split.personal.rating,
      canonical: split.canonical,
      personal: split.personal,
      unknownFields: split.unknownFields,
    );
  }

  /// Split ComicInfo.xml into canonical metadata and local personal state.
  ComicInfoImportSplit splitForImport(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final root = document.rootElement;
    if (root.localName != 'ComicInfo') {
      throw FormatException(
        'Expected <ComicInfo> root element, got <${root.localName}>',
      );
    }

    final fields = <String, String>{
      for (final el in root.children.whereType<XmlElement>())
        el.localName: el.innerText.trim(),
    };

    final title = _text(root, 'Title') ?? _text(root, 'Series') ?? 'Unknown';
    final series = _text(root, 'Series') ?? title;
    final number = _text(root, 'Number');
    final volume = _parseInt(root, 'Volume');
    final summary = _text(root, 'Summary');
    final year = _parseInt(root, 'Year');
    final month = _parseInt(root, 'Month');
    final day = _parseInt(root, 'Day');
    final publisher = _text(root, 'Publisher');
    final format = _text(root, 'Format');
    final notes = _text(root, 'Notes');
    final tags = _text(root, 'Tags');
    final ratingText = _text(root, 'CommunityRating');
    final communityRating = ratingText == null
        ? null
        : (double.tryParse(ratingText)?.clamp(0, 5).toDouble());

    DateTime? releaseDate;
    if (year != null) {
      releaseDate = DateTime(year, month ?? 1, day ?? 1);
    }

    final canonical = ComicInfoCanonicalCandidate(
      title: title,
      seriesTitle: series,
      itemNumber: number,
      volumeNumber: volume,
      synopsis: summary,
      publisher: publisher,
      releaseDate: releaseDate,
      releaseYear: year,
      physicalFormatLabel: format,
    );

    final personal = ComicInfoPersonalState(
      notes: notes,
      tags: tags,
      rating: communityRating != null ? (communityRating * 2).round() : null,
      localOnlyFields: {
        for (final entry in fields.entries)
          if (!_isCanonicalField(entry.key) && !_isPersonalField(entry.key))
            entry.key: entry.value,
      },
    );

    return ComicInfoImportSplit(
      canonical: canonical,
      personal: personal,
      unknownFields: {
        for (final entry in fields.entries)
          if (!_isCanonicalField(entry.key) && !_isPersonalField(entry.key))
            entry.key: entry.value,
      },
    );
  }

  void _optionalElement(XmlBuilder builder, String name, String? value) {
    if (value != null && value.trim().isNotEmpty) {
      builder.element(name, nest: value);
    }
  }

  String? _text(XmlElement root, String name) {
    final el = root.findElements(name).firstOrNull;
    final text = el?.innerText.trim();
    return (text == null || text.isEmpty) ? null : text;
  }

  int? _parseInt(XmlElement root, String name) {
    final text = _text(root, name);
    return text == null ? null : int.tryParse(text);
  }

  bool _isCanonicalField(String name) {
    return {
      'Title',
      'Series',
      'Number',
      'Volume',
      'Summary',
      'Year',
      'Month',
      'Day',
      'Publisher',
      'Format',
    }.contains(name);
  }

  bool _isPersonalField(String name) {
    return {
      'Notes',
      'Tags',
      'CommunityRating',
    }.contains(name);
  }
}

@immutable
class ComicInfoImportSplit {
  const ComicInfoImportSplit({
    required this.canonical,
    required this.personal,
    required this.unknownFields,
  });

  final ComicInfoCanonicalCandidate canonical;
  final ComicInfoPersonalState personal;
  final Map<String, String> unknownFields;
}

@immutable
class ComicInfoCanonicalCandidate {
  const ComicInfoCanonicalCandidate({
    required this.title,
    this.seriesTitle,
    this.itemNumber,
    this.volumeNumber,
    this.synopsis,
    this.publisher,
    this.releaseDate,
    this.releaseYear,
    this.physicalFormatLabel,
  });

  final String title;
  final String? seriesTitle;
  final String? itemNumber;
  final int? volumeNumber;
  final String? synopsis;
  final String? publisher;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? physicalFormatLabel;
}

@immutable
class ComicInfoPersonalState {
  const ComicInfoPersonalState({
    this.notes,
    this.tags,
    this.rating,
    this.localOnlyFields = const {},
  });

  final String? notes;
  final String? tags;
  final int? rating;
  final Map<String, String> localOnlyFields;
}

/// Parsed ComicInfo.xml data.
class ComicInfoData {
  const ComicInfoData({
    required this.title,
    this.seriesTitle,
    this.itemNumber,
    this.volumeNumber,
    this.synopsis,
    this.publisher,
    this.releaseDate,
    this.releaseYear,
    this.physicalFormatLabel,
    this.notes,
    this.tags,
    this.rating,
    this.canonical,
    this.personal,
    this.unknownFields = const {},
  });

  final String title;
  final String? seriesTitle;
  final String? itemNumber;
  final int? volumeNumber;
  final String? synopsis;
  final String? publisher;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? physicalFormatLabel;
  final String? notes;
  final String? tags;
  final int? rating;
  final ComicInfoCanonicalCandidate? canonical;
  final ComicInfoPersonalState? personal;
  final Map<String, String> unknownFields;
}
