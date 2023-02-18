import 'package:flutter/material.dart';

class MusicPlayerTheme {
  final primaryListTileColor = const Color(0xFF50577A);
  final primaryAppBarColor = const Color(0xFF404258);
  final primaryBottomSheetColor = const Color(0xFF50577A);
  final primaryDefaultArtworkBackgroundColor = const Color(0xFF474E68);
  final primaryColor = const Color(0xFFFFFFFF);
  final secondaryColor = const Color(0xFFCCCCCC);
  final tertiaryColor = const Color(0xFF404258);

  final progressBaseColor = const Color(0xFF3D8361);

  final progressBarColor = const Color(0xFF1DB954);

  final musicVisualiser = const Color(0xFF1DB954);
  final selectedTile = const Color.fromARGB(255, 31, 236, 103);
  final iconColor = const Color(0xFFFFFFFF);

  final linearGradientBody = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF404258),
      Color(0xFF474E68),
      Color(0xFF50577A),
    ],
  );
}
