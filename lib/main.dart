import 'package:flutter/material.dart';
import 'package:music_player/components/music_player_theme.dart';
import 'package:music_player/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              backgroundColor: MusicPlayerTheme().primaryAppBarColor)),
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}
