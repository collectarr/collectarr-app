import 'package:collectarr_app/ui/app_chrome.dart';
import 'package:collectarr_app/ui/app_dark_chrome.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'dart:math' as math;

/// Secondary navigation below the persistent application bar.
class AppPageHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.icon,
    this.leading,
    this.actions,
    this.bottom,
    this.svgAsset,
  }) : assert(icon != null || svgAsset != null);

  final Widget title;
  final IconData? icon;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final String? svgAsset;

  @override
  Size get preferredSize => Size.fromHeight(
      secondaryHeaderHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: appManagementPanelColor(context),
      child: SafeArea(
        bottom: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // The reference keeps this bar dark in its light skin too.
          AppDarkChrome(
              child: Builder(
                  builder: (context) => ColoredBox(
                      color: appManagementPanelColor(context),
                      child: _bar(context)))),
          if (bottom != null) bottom!,
        ]),
      ),
    );
  }

  Widget _bar(BuildContext context) {
    final palette = appPalette(context);
    return SizedBox(
      height: secondaryHeaderHeight,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: IconTheme(
            data: IconThemeData(size: 16, color: palette.textPrimary),
            child: DefaultTextStyle(
              style: TextStyle(
                  fontFamily: appFontFamily,
                  height: 20 / 16,
                  color: palette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: Stack(children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                            math.max(80.0, (actions?.length ?? 0) * 48.0)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (svgAsset != null)
                            SvgPicture.asset(svgAsset!,
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                    palette.textPrimary, BlendMode.srcIn))
                          else
                            Icon(icon),
                          const SizedBox(width: 6),
                          Flexible(child: title),
                        ]),
                  ),
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                        width: 80,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: leading ?? const AppPageBackButton()))),
                if (actions?.isNotEmpty ?? false)
                  Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                          mainAxisSize: MainAxisSize.min, children: actions!)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class AppPageBackButton extends StatelessWidget {
  const AppPageBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed ??
            () {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                navigator.pop();
              } else {
                final kind = LibraryAccentScope.maybeOf(context)?.kind;
                context.go(kind == null
                    ? AppRoutes.libraries
                    : AppRoutes.forKind(AppRoutes.libraries, kind));
              }
            },
        style: TextButton.styleFrom(
          foregroundColor: appPalette(context).textPrimary,
          backgroundColor: Colors.transparent,
          minimumSize: const Size(0, 30),
          maximumSize: const Size(double.infinity, 30),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          overlayColor:
              appPalette(context).isDark ? Colors.white : Colors.black,
          textStyle: TextStyle(
              fontFamily: appFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(AppIcons.chevronLeft, size: 14),
          SizedBox(width: 2.5),
          Flexible(
              child:
                  Text('Back', maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      );
}
