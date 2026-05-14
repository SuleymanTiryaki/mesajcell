import 'package:flutter/material.dart';
import '../extension/string_extension.dart';
import 'locale_keys.g.dart';

/// Uygulama genelinde kullanılan tüm string sabitler burada tanımlıdır.
class ConstantString {
  ConstantString._();

  // Localization
  static const supportedLocales = [trLocale, enLocale];
  static const trLocale = Locale('tr', 'TR');
  static const enLocale = Locale('en', 'EN');
  static const langPath = 'assets/lang';

  // Assets
  // static const appLogo = 'assets/images/logo.png';

  // Localized getters
  static String get chats => LocaleKeys.chats.locale;
  static String get search => LocaleKeys.search.locale;
  static String get noResultFound => LocaleKeys.noResultFound.locale;
  static String get newChat => LocaleKeys.newChat.locale;
  static String get lastSeen => LocaleKeys.lastSeen.locale;
  static String get online => LocaleKeys.online.locale;
  static String get yesterday => LocaleKeys.yesterday.locale;
  static String get settings => LocaleKeys.settings.locale;
  static String get profile => LocaleKeys.profile.locale;
  static String get logout => LocaleKeys.logout.locale;
}
