import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

Color appDropdownMenuSurface(BuildContext context) => appPalette(context).isDark
    ? const Color(0xff444444)
    : appPalette(context).panelRaised;

Color appDropdownMenuBorder(BuildContext context) => appPalette(context).isDark
    ? const Color(0xff666666)
    : appPalette(context).divider;

RoundedRectangleBorder appDropdownMenuShape(BuildContext context) =>
    RoundedRectangleBorder(
        side: BorderSide(color: appDropdownMenuBorder(context)));
