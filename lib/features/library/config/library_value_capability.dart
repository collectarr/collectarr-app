import 'package:collectarr_app/features/library/generic/projection_item.dart';

abstract interface class LibraryValueCapability {
  int? resolveProviderValueCents(LibraryProjectionRuntime item);
}

class DefaultLibraryValueCapability implements LibraryValueCapability {
  const DefaultLibraryValueCapability();

  @override
  int? resolveProviderValueCents(LibraryProjectionRuntime item) => null;
}
