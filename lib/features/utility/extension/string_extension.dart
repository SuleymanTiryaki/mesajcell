import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

extension StringLocalization on String {
  /// Locale'den çeviri döndürür.
  // ignore: prefer_interpolation_to_compose_strings
  String get locale => this.tr();

  /// Parametreli çeviri döndürür.
  String localArg(List<String> args) => this.tr(args: args);
}

extension HexColor on String {
  Color toColor() {
    final hex = replaceAll('#', '');
    return Color(int.parse('0xFF$hex'));
  }
}
