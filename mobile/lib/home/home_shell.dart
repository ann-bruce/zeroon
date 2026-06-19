import 'package:flutter/material.dart';

import '../auth/auth_models.dart';
import '../record/archive_screen.dart';
import '../record/reset_screen.dart';
import 'now_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.session});

  final AuthSession session;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      NowScreen(session: widget.session),
      const ResetScreen(),
      const ArchiveScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.radio_button_checked),
            label: 'Now',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'Reset',
          ),
          NavigationDestination(
            icon: Icon(Icons.archive_outlined),
            label: 'Archive',
          ),
        ],
      ),
    );
  }
}
