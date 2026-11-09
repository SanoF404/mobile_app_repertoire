import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Illustration décorative montrant un répertoire relié à des contacts.
class DirectoryIllustration extends StatelessWidget {
  const DirectoryIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    // Le Stack permet de positionner les contacts autour de l'icône centrale.
    return SizedBox(
      height: 235,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 12,
            top: 35,
            child: _contactCard(color: const Color(0xFF7389AE), size: 64),
          ),
          Positioned(
            right: 12,
            top: 35,
            child: _contactCard(color: const Color(0xFF8799B7), size: 64),
          ),
          Positioned(
            left: 72,
            bottom: 17,
            child: _contactCard(color: const Color(0xFF526F9D), size: 75),
          ),
          Positioned(
            right: 72,
            bottom: 17,
            child: _contactCard(color: const Color(0xFF526F9D), size: 75),
          ),
          Container(
            width: 102,
            height: 102,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFD0D3DC),
                  offset: Offset(6, 6),
                  blurRadius: 13,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(-6, -6),
                  blurRadius: 13,
                ),
              ],
            ),
            child: const Icon(
              Icons.contacts_rounded,
              color: AppColors.navy,
              size: 53,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _connectionLine(),
                const SizedBox(width: 8),
                const Icon(
                  Icons.phone_in_talk_rounded,
                  size: 21,
                  color: AppColors.navy,
                ),
                const SizedBox(width: 8),
                _connectionLine(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dessine un contact circulaire avec une icône de personne.
  Widget _contactCard({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0xFFD2D5DD),
            offset: Offset(4, 4),
            blurRadius: 9,
          ),
          BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 9),
        ],
      ),
      child: Icon(Icons.person_rounded, size: size * 0.55, color: color),
    );
  }

  // Petit trait décoratif reliant le téléphone au répertoire.
  Widget _connectionLine() {
    return Container(width: 48, height: 2, color: const Color(0xFF9AA8BF));
  }
}
