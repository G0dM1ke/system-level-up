import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'quests.dart';
import 'stats.dart';
import 'supplements.dart';
import 'journal.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  final pages = const [
    DashboardScreen(),
    QuestsScreen(),
    StatsScreen(),
    SupplementsScreen(),
    JournalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.shield), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Dungeon'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.medication), label: 'Arsenal'),
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'Log'),
        ],
      ),
    );
  }
}
