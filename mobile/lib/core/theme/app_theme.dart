import 'package:flutter/material.dart';

/// Palette partagée par les différents écrans et composants.
abstract final class AppColors {
  static const background = Color(0xFFEAECF1);
  static const navy = Color.fromARGB(255, 103, 32, 104);
  static const text = Color(0xFF17283F);
}

/// Thème général utilisé par MaterialApp.
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
  );
}

/// Crée le relief doux utilisé pour les champs et boutons.
/// `pressed` choisit des ombres plus rapprochées pour l'état enfoncé.
BoxDecoration neumorphicDecoration({double radius = 28, bool pressed = false}) {
  return BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: pressed
        ? const [
            BoxShadow(
              color: Color(0xFFD1D4DC),
              offset: Offset(5, 5),
              blurRadius: 10,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-5, -5),
              blurRadius: 10,
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0xFFD0D3DC),
              offset: Offset(7, 7),
              blurRadius: 14,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-7, -7),
              blurRadius: 14,
            ),
          ],
  );
}
