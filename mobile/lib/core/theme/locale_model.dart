import 'package:flutter/material.dart';

class LocaleModel extends ChangeNotifier {
  Locale locale = const Locale('fr');
  void toggle() {
    locale = locale.languageCode == 'fr'
        ? const Locale('ar')
        : const Locale('fr');
    notifyListeners();
  }
}
