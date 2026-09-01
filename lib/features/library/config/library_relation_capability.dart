import 'package:collectarr_app/core/models/library_relation_node.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

class LibraryRelationCapability {
  const LibraryRelationCapability({
    required this.targetFor,
    required this.openTarget,
  });

  final LibraryRelationTarget? Function(LibraryProjectionRuntime item)
      targetFor;
  final void Function(BuildContext context, LibraryRelationTarget target)
      openTarget;
}
