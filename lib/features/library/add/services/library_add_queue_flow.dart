import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_action_service.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:flutter/material.dart';

Future<void> queueLibraryAddProviderIngestFlow({
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
}) async {
  if (isQueueingIngest) {
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  rebuild(() {
    setQueueingIngest(true);
    setError(null);
  });
  try {
    final job = await providerActionService.queueIngest(
      api: api,
      candidate: candidate,
    );
    if (!mounted) {
      return;
    }
    rebuild(() {
      onQueued(LibraryQueuedProviderIngest(id: job.id, status: job.status));
    });
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Queued ${candidate.title} ingest job ${job.id} (${job.status}).',
        ),
      ),
    );
  } catch (error) {
    if (mounted) {
      if (await clearRejectedMetadataSession(error, 'Core ingest queue')) {
        return;
      }
      rebuild(() {
        setError(
          'Core ingest queue failed: '
          '${ConnectionDiagnostics.metadataError(error, api.baseUrl)} '
          'Admin access is required to queue canonical ingest jobs.',
        );
      });
    }
  } finally {
    if (mounted) {
      rebuild(() {
        setQueueingIngest(false);
      });
    }
  }
}
