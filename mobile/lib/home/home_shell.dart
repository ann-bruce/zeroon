import 'package:flutter/material.dart';

import '../auth/auth_models.dart';
import '../common/zeroon_design.dart';
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
      NowScreen(
        session: widget.session,
        onStartReset: () => setState(() => _selectedIndex = 1),
      ),
      ResetScreen(onReturnHome: () => setState(() => _selectedIndex = 0)),
      const ArchiveScreen(),
    ];

    return Scaffold(
      backgroundColor: zeroonPaper,
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 74,
        decoration: BoxDecoration(
          color: zeroonPaper.withValues(alpha: 0.94),
          border: const Border(top: BorderSide(color: zeroonLine)),
        ),
        padding: const EdgeInsets.fromLTRB(34, 4, 34, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              icon: Icons.radio_button_checked,
              label: '此刻',
              selected: _selectedIndex == 0,
              onTap: () => setState(() => _selectedIndex = 0),
            ),
            _NavItem(
              icon: Icons.add_circle_outline,
              label: '归零',
              selected: _selectedIndex == 1,
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            _NavItem(
              icon: Icons.inventory_2_outlined,
              label: '缓存',
              selected: _selectedIndex == 2,
              onTap: () => setState(() => _selectedIndex = 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? zeroonNight : const Color(0xFFA09F9C);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 74,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 62,
              height: 31,
              decoration: BoxDecoration(
                color: selected
                    ? zeroonCyan.withValues(alpha: 0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
