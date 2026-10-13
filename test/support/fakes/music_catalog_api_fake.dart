import 'dart:typed_data';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:dio/dio.dart';

import '../builders/catalog_item_builder.dart';

class MusicCatalogApiFake extends ApiClient {
  MusicCatalogApiFake({
    this.searchId = 'music-1',
    this.title = 'Batman',
    String Function(String)? barcodeId,
  })  : barcodeId = barcodeId ?? ((_) => 'music-1'),
        super(baseUrl: 'http://unused', dio: _isolatedDio());

  final String searchId;
  final String title;
  final String Function(String) barcodeId;
  MetadataSearchQuery? lastSearchQuery;
  String? lastBarcode;
  String? lastBarcodeKind;

  @override
  Future<Map<String, dynamic>> getJsonObject(
    String path, {
    Map<String, Object?>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    if (path != '/api/v1/metadata/music/items') {
      throw StateError('Unexpected test request: $path');
    }
    final query = queryParameters ?? const <String, Object?>{};
    final barcode = query['barcode'] as String?;
    if (barcode == '000000000000') throw StateError('Missing barcode');
    if (barcode != null) {
      lastBarcode = barcode;
      lastBarcodeKind = 'music';
    } else {
      lastSearchQuery = MetadataSearchQuery(
        query: query['q'] as String?,
        kind: 'music',
        series: query['artist'] as String?,
        year: query['year'] as int?,
        limit: query['limit'] as int?,
        offset: query['offset'] as int?,
      );
    }
    return {
      'items': [
        testCatalogItem(
          id: barcode == null ? searchId : barcodeId(barcode),
          kind: 'music',
          title: title,
          barcode: barcode,
        ).toJson()
      ],
      'has_more': false,
      'next_offset': null,
    };
  }
}

Dio _isolatedDio() => Dio(BaseOptions(baseUrl: 'http://unused'))
  ..httpClientAdapter = _RejectUnexpectedNetwork();

class _RejectUnexpectedNetwork implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      throw StateError(
          'Unexpected test HTTP request: ${options.method} ${options.path}');
  @override
  void close({bool force = false}) {}
}
