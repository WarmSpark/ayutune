import 'package:flutter/material.dart';
import '../theme/retro_theme.dart';

class RetroWindowHeader extends StatelessWidget {
  final RetroThemeData theme;
  final String title;
  final VoidCallback? onFilesTap;
  final VoidCallback? onThemeTap;

  const RetroWindowHeader({
    super.key,
    required this.theme,
    this.title = 'ayutune.apk',
    this.onFilesTap,
    this.onThemeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.panel,
        border: Border(
          bottom: BorderSide(color: theme.ink, width: 2.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _menuItem('APP', null),
              const SizedBox(width: 8),
              _menuItem('FILES', onFilesTap),
              const SizedBox(width: 8),
              _menuItem('THEMES', onThemeTap),
            ],
          ),
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.ink,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.ink, width: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuItem(String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: theme.ink,
          ),
        ),
      ),
    );
  }
}

class RetroNavTabs extends StatelessWidget {
  final RetroThemeData theme;
  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  const RetroNavTabs({
    super.key,
    required this.theme,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.panel,
        border: Border(
          bottom: BorderSide(color: theme.ink, width: 2.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          _tabButton('NOW PLAYING', 0),
          const SizedBox(width: 8),
          _tabButton('SONGS CATALOG', 1),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? theme.accentCoral : theme.background,
          border: Border.all(color: theme.ink, width: 2),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: theme.ink,
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : theme.ink,
          ),
        ),
      ),
    );
  }
}
