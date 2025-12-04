import 'dart:ui';

import 'package:flutter/material.dart';
import 'ScanMushroom.dart';
import 'ChatBot.dart';
import 'Config.dart';

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    ChatBotScreen(),
    ScanMushroomScreen(),
    ConfigScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: [
              BottomNavigationBarItem(
                icon: AnimatedScale(
                  scale: _currentIndex == 0 ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.chat_rounded),
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: AnimatedScale(
                  scale: _currentIndex == 1 ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.camera_alt_rounded),
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: AnimatedScale(
                  scale: _currentIndex == 2 ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.settings),
                ),
                label: "",
              ),
            ],
          )
        ),
      ),
    );
  }
}
