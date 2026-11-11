import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/localization/app_locale.dart';
import '../core/localization/app_localizations.dart';
import '../data/services/mock_backend_store.dart';

class PadCareApp extends ConsumerStatefulWidget {
  const PadCareApp({super.key});

  @override
  ConsumerState<PadCareApp> createState() => _PadCareAppState();
}

class _PadCareAppState extends ConsumerState<PadCareApp> {
  final MockBackendStore _store = MockBackendStore();

  @override
  Widget build(BuildContext context) {
    final user = _store.currentUser;
    final currentLocale = AppLocales.getLocale(user.selectedLocale);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: AppTheme.getTheme(),
      locale: currentLocale,
      supportedLocales: AppLocales.all.map((l) => Locale(l.code)),
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
