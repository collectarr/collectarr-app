import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/widgets.dart';

enum DrawerAction {
  addFromCore,
  managePickLists,
  manageCollections,
  printToPdf,
  statistics,
  findDuplicates,
  loanManager,
  calendar,
  admin,
  manageCustomFields,
  cloudSharing,
  prefillSettings,
  settings,
  reassignIndex,
  backupRestore,
  clearDatabase,
  transferFieldData,
  exportCsv,
  exportXml,
  importData,
  linkItems,
  userManual,
  community,
  contactSupport,
  whatsNew,
  keyboardShortcuts,
}

enum DrawerActionBehavior {
  routedPage,
  overlayPage,
  modal,
  libraryTool,
  libraryAdd,
  externalLink
}

enum AppDrawerSection {
  collection('Collection'),
  tools('Tools'),
  administration('Administration'),
  customization('Customization'),
  maintenance('Maintenance'),
  importExport('Import / Export'),
  help('Help');

  const AppDrawerSection(this.label);
  final String label;
  bool get collapsible =>
      this == maintenance || this == importExport || this == help;
}

class AppDrawerDestination {
  const AppDrawerDestination(
      {required this.action,
      required this.label,
      this.icon,
      this.svgAsset,
      required this.section,
      required this.behavior,
      this.routePath,
      this.adminOnly = false,
      this.widgetKey})
      : assert(icon != null || svgAsset != null);
  final DrawerAction action;
  final String label;
  final IconData? icon;
  final String? svgAsset;
  final AppDrawerSection section;
  final DrawerActionBehavior behavior;
  final String? routePath;
  final bool adminOnly;
  final String? widgetKey;
  bool get routesAway =>
      behavior == DrawerActionBehavior.routedPage ||
      behavior == DrawerActionBehavior.libraryTool ||
      behavior == DrawerActionBehavior.libraryAdd;
  bool get resetsToLibrary => behavior == DrawerActionBehavior.overlayPage;
}

const appDrawerDestinations = <AppDrawerDestination>[
  AppDrawerDestination(
      action: DrawerAction.addFromCore,
      label: 'Add from Core',
      icon: AppIcons.add,
      section: AppDrawerSection.collection,
      behavior: DrawerActionBehavior.libraryAdd),
  AppDrawerDestination(
      action: DrawerAction.managePickLists,
      label: 'Manage Pick Lists',
      icon: AppIcons.pickLists,
      section: AppDrawerSection.collection,
      behavior: DrawerActionBehavior.modal),
  AppDrawerDestination(
      action: DrawerAction.manageCollections,
      label: 'Manage Collections',
      icon: AppIcons.collections,
      section: AppDrawerSection.collection,
      behavior: DrawerActionBehavior.modal),
  AppDrawerDestination(
      action: DrawerAction.printToPdf,
      label: 'Print to PDF',
      icon: AppIcons.print,
      section: AppDrawerSection.tools,
      behavior: DrawerActionBehavior.overlayPage),
  AppDrawerDestination(
      action: DrawerAction.statistics,
      label: 'Statistics',
      icon: AppIcons.statistics,
      section: AppDrawerSection.tools,
      behavior: DrawerActionBehavior.overlayPage),
  AppDrawerDestination(
      action: DrawerAction.findDuplicates,
      label: 'Find Duplicates',
      icon: AppIcons.duplicates,
      section: AppDrawerSection.tools,
      behavior: DrawerActionBehavior.overlayPage),
  AppDrawerDestination(
      action: DrawerAction.loanManager,
      label: 'Loan Manager',
      icon: AppIcons.loans,
      section: AppDrawerSection.tools,
      behavior: DrawerActionBehavior.routedPage,
      routePath: AppRoutes.loans,
      widgetKey: 'nav.more'),
  AppDrawerDestination(
      action: DrawerAction.calendar,
      label: 'Calendar',
      icon: AppIcons.calendar,
      section: AppDrawerSection.tools,
      behavior: DrawerActionBehavior.routedPage,
      routePath: AppRoutes.calendar,
      widgetKey: 'nav.calendar'),
  AppDrawerDestination(
      action: DrawerAction.admin,
      label: 'Admin',
      icon: AppIcons.admin,
      section: AppDrawerSection.administration,
      behavior: DrawerActionBehavior.routedPage,
      routePath: AppRoutes.admin,
      adminOnly: true),
  AppDrawerDestination(
      action: DrawerAction.manageCustomFields,
      label: 'Manage Custom Fields',
      svgAsset: AppIcons.customFieldsSvg,
      section: AppDrawerSection.customization,
      behavior: DrawerActionBehavior.overlayPage),
  AppDrawerDestination(
      action: DrawerAction.cloudSharing,
      label: 'Cloud Sync & Sharing',
      icon: AppIcons.cloudSharing,
      section: AppDrawerSection.customization,
      behavior: DrawerActionBehavior.overlayPage),
  AppDrawerDestination(
      action: DrawerAction.prefillSettings,
      label: 'Pre-fill Settings',
      icon: AppIcons.prefill,
      section: AppDrawerSection.customization,
      behavior: DrawerActionBehavior.modal),
  AppDrawerDestination(
      action: DrawerAction.settings,
      label: 'Settings',
      icon: AppIcons.settings,
      section: AppDrawerSection.customization,
      behavior: DrawerActionBehavior.routedPage,
      routePath: AppRoutes.settings),
  AppDrawerDestination(
      action: DrawerAction.reassignIndex,
      label: 'Re-Assign Index Values',
      icon: AppIcons.reassignIndex,
      section: AppDrawerSection.maintenance,
      behavior: DrawerActionBehavior.libraryTool),
  AppDrawerDestination(
      action: DrawerAction.backupRestore,
      label: 'Backup / Restore',
      icon: AppIcons.backupRestore,
      section: AppDrawerSection.maintenance,
      behavior: DrawerActionBehavior.routedPage),
  AppDrawerDestination(
      action: DrawerAction.clearDatabase,
      label: 'Clear Database',
      icon: AppIcons.clearDatabase,
      section: AppDrawerSection.maintenance,
      behavior: DrawerActionBehavior.routedPage),
  AppDrawerDestination(
      action: DrawerAction.transferFieldData,
      label: 'Transfer Field Data',
      icon: AppIcons.transferFieldData,
      section: AppDrawerSection.maintenance,
      behavior: DrawerActionBehavior.libraryTool),
  AppDrawerDestination(
      action: DrawerAction.exportCsv,
      label: 'Export to CSV / TXT',
      icon: AppIcons.exportCsv,
      section: AppDrawerSection.importExport,
      behavior: DrawerActionBehavior.overlayPage),
  AppDrawerDestination(
      action: DrawerAction.exportXml,
      label: 'Export to XML',
      icon: AppIcons.exportXml,
      section: AppDrawerSection.importExport,
      behavior: DrawerActionBehavior.modal),
  AppDrawerDestination(
      action: DrawerAction.importData,
      label: 'Import Data',
      icon: AppIcons.importData,
      section: AppDrawerSection.importExport,
      behavior: DrawerActionBehavior.overlayPage),
  AppDrawerDestination(
      action: DrawerAction.linkItems,
      label: 'Link Items',
      icon: AppIcons.link,
      section: AppDrawerSection.importExport,
      behavior: DrawerActionBehavior.overlayPage),
  AppDrawerDestination(
      action: DrawerAction.userManual,
      label: 'Manual',
      icon: AppIcons.userManual,
      section: AppDrawerSection.help,
      behavior: DrawerActionBehavior.externalLink,
      widgetKey: 'drawer.user-manual'),
  AppDrawerDestination(
      action: DrawerAction.community,
      label: 'Community',
      svgAsset: AppIcons.communitySvg,
      section: AppDrawerSection.help,
      behavior: DrawerActionBehavior.externalLink,
      widgetKey: 'drawer.community'),
  AppDrawerDestination(
      action: DrawerAction.contactSupport,
      label: 'Contact Support',
      icon: AppIcons.contactSupport,
      section: AppDrawerSection.help,
      behavior: DrawerActionBehavior.externalLink,
      widgetKey: 'drawer.contact-support'),
  AppDrawerDestination(
      action: DrawerAction.whatsNew,
      label: "What's New?",
      icon: AppIcons.whatsNew,
      section: AppDrawerSection.help,
      behavior: DrawerActionBehavior.externalLink,
      widgetKey: 'drawer.whats-new'),
  AppDrawerDestination(
      action: DrawerAction.keyboardShortcuts,
      label: 'Keyboard Shortcuts',
      icon: AppIcons.keyboard,
      section: AppDrawerSection.help,
      behavior: DrawerActionBehavior.modal),
];
AppDrawerDestination appDrawerDestination(DrawerAction action) =>
    appDrawerDestinations
        .firstWhere((destination) => destination.action == action);
DrawerAction? appDrawerActionForRoute(String path) => appDrawerDestinations
    .where((destination) => destination.routePath == path)
    .firstOrNull
    ?.action;
