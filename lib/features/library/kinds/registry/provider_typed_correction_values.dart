import 'package:collectarr_app/features/providers/transport/provider_patch.dart';

ProviderPatch<String> providerStringPatch(String? current, String? updated) {
  if (current == updated) return const ProviderPatch.unchanged();
  return updated == null
      ? const ProviderPatch.clear()
      : ProviderPatch.set(updated);
}

ProviderPatch<DateTime> providerDatePatch(
  DateTime? current,
  DateTime? updated,
) {
  if (current == updated) return const ProviderPatch.unchanged();
  return updated == null
      ? const ProviderPatch.clear()
      : ProviderPatch.set(updated);
}

bool providerPatchIsUnchanged(Object patch) => patch is ProviderUnchanged;
