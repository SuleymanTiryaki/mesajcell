import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:mesajcell/features/utility/const/constant_string.dart';
import 'package:mesajcell/features/utility/notifier/theme_notifier.dart';
import 'package:mesajcell/features/utility/theme/app_theme.dart';
import 'package:mesajcell/features/core/app_session.dart';
import 'package:mesajcell/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await AppSession.instance.initFromStorage();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: EasyLocalization(
        supportedLocales: ConstantString.supportedLocales,
        path: ConstantString.langPath,
        fallbackLocale: ConstantString.trLocale,
        startLocale: ConstantString.trLocale,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    return MaterialApp.router(
      title: 'MesajCell',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeNotifier.themeMode,
      routerConfig: appRouter,
    );
  }
}
