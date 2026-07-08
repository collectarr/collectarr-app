import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/services/library_add_queue_flow.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_action_service.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:flutter/material.dart';

class LibraryAddProviderFlowService {
  const LibraryAddProviderFlowService();

  Future<void> queueProviderIngest({
    required BuildContext context,
    required ApiClient api,
    required ProviderCandidate candidate,
    required LibraryProviderActionService providerActionService,
    required bool mounted,
    required bool isQueueingIngest,
    required Future<bool> Function(Object error, String action)
        clearRejectedMetadataSession,
    required void Function(VoidCallback fn) rebuild,
    required void Function(bool value) setQueueingIngest,
    required void Function(LibraryQueuedProviderIngest ingest) onQueued,
    required void Function(String? message) setError,
  }) {
    return queueLibraryAddProviderIngestFlow(
      context: context,
      api: api,
      candidate: candidate,
      providerActionService: providerActionService,
      mounted: mounted,
      isQueueingIngest: isQueueingIngest,
      clearRejectedMetadataSession: clearRejectedMetadataSession,
      rebuild: rebuild,
      setQueueingIngest: setQueueingIngest,
      onQueued: onQueued,
      setError: setError,
    );
  }
}
