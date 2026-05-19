import 'package:collectarr_app/features/comics/workspace/comics_workspace_control_models.dart';
import 'package:collectarr_app/features/library/workspace/library_view_table_controls.dart';
import 'package:flutter/material.dart';

class ComicsViewTableControls extends StatelessWidget {
  const ComicsViewTableControls({
    super.key,
    required this.state,
    required this.callbacks,
  });

  final ComicsViewTableControlState state;
  final ComicsViewTableControlCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return LibraryViewTableControls(
      state: state,
      callbacks: callbacks,
    );
  }
}
