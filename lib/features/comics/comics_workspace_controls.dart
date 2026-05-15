import 'package:collectarr_app/features/comics/comics_selection_controls.dart';
import 'package:collectarr_app/features/comics/comics_view_table_controls.dart';
import 'package:collectarr_app/features/comics/comics_workspace_control_models.dart';
import 'package:collectarr_app/features/comics/comics_workspace_utility_controls.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/comics/comics_selection_controls.dart';
export 'package:collectarr_app/features/comics/comics_view_table_controls.dart';
export 'package:collectarr_app/features/comics/comics_workspace_control_models.dart';
export 'package:collectarr_app/features/comics/comics_workspace_utility_controls.dart';

class ComicsWorkspaceControlStrip extends StatelessWidget {
  const ComicsWorkspaceControlStrip({
    super.key,
    required this.state,
    required this.callbacks,
  });

  final ComicsWorkspaceControlState state;
  final ComicsWorkspaceControlCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ComicsSelectionControls(
                state: state.selection,
                callbacks: callbacks.selection,
              ),
              const SizedBox(width: 6),
              ComicsWorkspaceUtilityControls(
                state: state.utility,
                callbacks: callbacks.utility,
              ),
              const SizedBox(width: 6),
              ComicsViewTableControls(
                state: state.view,
                callbacks: callbacks.view,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
