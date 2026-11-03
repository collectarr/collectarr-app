import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppShellBrand extends StatelessWidget {
  const AppShellBrand({
    super.key,
    required this.icon,
    required this.kindTitle,
    required this.iconKey,
    required this.titleKey,
    this.showIcon = true,
  });

  final IconData icon;
  final String kindTitle;
  final Key iconKey;
  final Key titleKey;
  final bool showIcon;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Icon(icon, key: iconKey, size: 22, color: Colors.white),
            const SizedBox(width: 7),
          ],
          Flexible(
            child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'CLR ${kindTitle.toUpperCase()}',
                  key: titleKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: appFontFamily,
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                )),
          ),
        ],
      );
}
