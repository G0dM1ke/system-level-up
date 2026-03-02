import 'package:flutter/material.dart';
import '../../services/prefs.dart';
import '../../services/xp_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalXp = 0;
  int streak = 0;
  String day = '';
  int dayXp = 0;
  String? weight;
  String? bp;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _rankFromXp(int xp) {
    if (xp >= 125) return 'S';
    if (xp >= 100) return 'A';
    if (xp >= 75) return 'B';
    if (xp >= 50) return 'C';
    if (xp >= 25) return 'D';
    return 'E';
  }

  Future<void> _load() async {
    day = await Prefs.todayKey();
    totalXp = await XpService.getTotalXp();
    streak = await XpService.getStreak();

    final st = await XpService.getDayState(day);
    dayXp = (st['dayXp'] as int?) ?? 0;

    weight = await Prefs.getString('latest_weight');
    bp = await Prefs.getString('latest_bp');

    setState(() {});
  }

  Future<void> _quickSetWeight() async {
    final ctrl = TextEditingController(text: weight ?? '');
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Weight'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'e.g. 400'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final v = ctrl.text.trim();
              await Prefs.setString('latest_weight', v);
              weight = v;
              if (!mounted) return;
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _quickSetBp() async {
    final ctrl = TextEditingController(text: bp ?? '');
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Blood Pressure'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(hintText: 'e.g. 146/81'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final v = ctrl.text.trim();
              await Prefs.setString('latest_bp', v);
              bp = v;
              if (!mounted) return;
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = XpService.levelFromTotalXp(totalXp);
    final into = XpService.xpIntoLevel(totalXp);
    final toNext = XpService.xpToNextLevel(totalXp);
    final rank = _rankFromXp(dayXp);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SYSTEM'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LEVEL $level', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: into / 250),
                  const SizedBox(height: 8),
                  Text('$into / 250 XP  •  $toNext XP to next level'),
                  const SizedBox(height: 8),
                  Text('Today: Rank $rank  •  XP $dayXp  •  Streak $streak'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 170,
                child: FilledButton.icon(
                  onPressed: _quickSetWeight,
                  icon: const Icon(Icons.monitor_weight),
                  label: const Text('Add Weight'),
                ),
              ),
              SizedBox(
                width: 170,
                child: FilledButton.icon(
                  onPressed: _quickSetBp,
                  icon: const Icon(Icons.favorite),
                  label: const Text('Add BP'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              title: const Text('Latest Weight'),
              subtitle: Text(weight ?? 'Not logged yet'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _quickSetWeight,
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Latest Blood Pressure'),
              subtitle: Text(bp ?? 'Not logged yet'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _quickSetBp,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                'SYSTEM MESSAGE:\n'
                'Quest accepted. Knee Armor protocol armed. Hydration rune charging.\n'
                'Minimum day = 3 quests (streak survives).',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
