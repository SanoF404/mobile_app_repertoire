import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/locale_model.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/sign_up_page.dart';
import '../features/auth/data_auth_service.dart';
import '../features/contacts/data/contact_repository.dart';
import '../features/contacts/presentation/contacts_page.dart';
import '../features/contacts/state/contacts_model.dart';
import '../features/comparison/presentation/comparison_page.dart';
import '../l10n/app_localizations.dart';

class PeopleoApp extends StatelessWidget {
  const PeopleoApp({super.key});
  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ContactsModel(RestRepository())),
      ChangeNotifierProvider(create: (_) => LocaleModel()),
    ],
    child: Consumer<LocaleModel>(
      builder: (context, locale, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Peopleo',
        theme: AppTheme.light,
        locale: locale.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: '/comparison',
        routes: {
          '/comparison': (_) => const ComparisonPage(),
          '/': (_) => FutureBuilder<String?>(
            future: AuthService.token(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return snapshot.data == null
                  ? const LoginPage()
                  : const ContactsPage();
            },
          ),
          '/login': (_) => const LoginPage(),
          '/signup': (_) => const SignUpPage(),
          '/contacts': (_) => const ContactsPage(),
        },
      ),
    ),
  );
}
