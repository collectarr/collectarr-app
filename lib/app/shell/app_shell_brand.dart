import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppShellBrand extends StatelessWidget {
  const AppShellBrand({
    super.key,
    required this.icon,
    required this.kindTitle,
    required this.iconKey,
    required this.titleKey,
  });

  final IconData icon;
  final String kindTitle;
  final Key iconKey;
  final Key titleKey;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, key: iconKey, size: 23, color: Colors.white),
          const SizedBox(width: 7),
          Flexible(
            child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'COLLECTARR ${kindTitle.toUpperCase()}',
                  key: titleKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: appFontFamily,
                    color: Colors.white,
                    fontSize: 24,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                )),
          ),
        ],
      );
}
