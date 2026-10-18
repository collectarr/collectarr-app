import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:flutter/material.dart';

/// Shows a toast from a settings section while it is still mounted.
extension SettingsToast on State {
  void showSettingsToast(String message,
      {AppToastTone tone = AppToastTone.info}) {
    if (!mounted) return;
    showAppToast(context, message, tone: tone);
  }
}

/// [error] as a message, without Dart's exception type prefix.
String describeSettingsError(Object error) {
  final text = error.toString().trim();
  if (text.startsWith('Exception: ')) {
    return text.substring('Exception: '.length);
  }
  if (text.startsWith('StateError: ')) {
    return text.substring('StateError: '.length);
  }
  return text;
}

/// [value] in local time as `yyyy-MM-dd HH:mm`.
String formatSettingsTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hour:$minute';
}

class SettingsTabBody extends StatelessWidget {
  const SettingsTabBody(
      {super.key, required this.children, this.twoColumns = false})
      : left = const [],
        right = const [],
        footer = null;

  /// Explicit reference columns: a 958 px page, 32 px between the columns
  /// and 37 px between boxes.
  const SettingsTabBody.columns({
    super.key,
    required this.left,
    required this.right,
    this.footer,
  })  : children = const [],
        twoColumns = true;

  final List<Widget> children;
  final bool twoColumns;
  final List<Widget> left;
  final List<Widget> right;
  final Widget? footer;

  Widget _explicitColumns(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        Widget column(List<Widget> boxes) =>
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (final box in boxes)
                Padding(padding: const EdgeInsets.only(bottom: 37), child: box)
            ]);
        final wide = constraints.maxWidth >= 800;
        return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 958),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (wide)
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: column(left)),
                                  const SizedBox(width: 32),
                                  Expanded(child: column(right)),
                                ])
                          else
                            column([...left, ...right]),
                          if (footer != null) footer!,
                        ]))));
      });

  @override
  Widget build(BuildContext context) => left.isNotEmpty || right.isNotEmpty
      ? _explicitColumns(context)
      : LayoutBuilder(builder: (context, constraints) {
          final wide = twoColumns && constraints.maxWidth >= 800;
          return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  for (var column = 0;
                                      column < 2;
                                      column++) ...[
                                    if (column != 0) const SizedBox(width: 28),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                          for (var index = column;
                                              index < children.length;
                                              index += 2)
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 20),
                                                child: children[index])
                                        ])),
                                  ],
                                ])
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                  for (final child in children)
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: child)
                                ]))));
        });
}

class SettingsResetAction extends StatelessWidget {
  const SettingsResetAction({
    super.key,
    required this.label,
    required this.onReset,
  });

  final String label;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: onReset,
        icon: const Icon(Icons.restart_alt),
        label: Text(label),
      ),
    );
  }
}

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: libraryWorkspaceBackgroundColor(context),
      // Reference settings boxes: 10 px padding, a 22/700 title and no rule.
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700, fontSize: 22),
            ),
            const SizedBox(height: 15),
            child,
          ],
        ),
      ),
    );
  }
}
