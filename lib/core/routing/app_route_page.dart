import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A route's page with the theme's page transition.
///
/// go_router recognises a Material app by the `MaterialApp` of the separate
/// material_ui package, not Flutter's own, so pages it builds itself for
/// this app get no transition. Routes build their pages with this instead.
Page<void> appRoutePage(GoRouterState state, Widget child) =>
    MaterialPage<void>(
      key: state.pageKey,
      name: state.name ?? state.path,
      arguments: {...state.pathParameters, ...state.uri.queryParameters},
      restorationId: state.pageKey.value,
      child: child,
    );
