import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/ui/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: IronPathApp(),
    ),
  );
}

class IronPathApp extends ConsumerWidget {
  const IronPathApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'IronPath',
      theme: buildIronLightTheme(),
      darkTheme: buildIronDarkTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
