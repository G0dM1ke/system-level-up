import 'package:flutter/material.dart';
import '../../models/quest.dart';
import '../../services/prefs.dart';
import '../../services/xp_service.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  final quests = const <Quest>[
    Quest(id: 'water', title: 'Hydration Rune — 2L water', xp: 15, easyTitle: 'Hydration Rune — 1.5L water', easyXp: 10),
    Quest(id: 'protein', title: 'Protein Anchor — 40g+ protein hit', xp: 15, easyTitle: 'Protein Anchor — 25g protein hit', easyXp: 10),
    Quest(id: 'steps', title: 'Step Quest — 10 min OR 1000 steps', xp: 20, easyTitle: 'Step Quest — 5 min', easyXp: 10),
    Quest(id: 'knee', title: 'Knee Armor — 5 min rehab/mobility', xp: 20, easyTitle: 'Knee Armor — 2 min', easyXp: 10),
    Quest(id: 'drinks', title: 'No Liquid Calories — no sweet drinks', xp: 15, easyTitle: 'Limit sweet drinks to 1', easyXp: 5),
    Quest(id: 'sleep', title: 'Sleep Shield — set bedtime + prep', xp: 10, easyTitle: 'Set alarm + prep', easyXp: 5),
    Quest(id: 'core', title: 'Core Stability — 5 min', xp: 15, easyTitle: 'Core Stability — 2 min', easyXp: 8),
    Quest(id: 'traps', title: 'Trap/Neck Forge — 3 sets', xp: 15, easyTitle: 'Trap/Neck Forge — 1 set', easyXp: 7),
    Quest(id: 'arsenal', title: 'Arsenal Check — meds/supps + log', xp: 10, easyTitle: 'Log it even if missed', easyXp: 3),
    Quest(id: 'log', title: 'System Log — enter ONE metric', xp: 10, easyTitle: 'Write 1 journal line', easyXp: 5),
  ];

  String day = '';
  Map<String, dynamic> state = {};
  int totalXp = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    day = await Prefs.todayKey();
    state = await XpService.getDayState(day);
    totalXp = await XpService.getTotalXp();
    if (state['dayXp'] == null) state['dayXp'] = 0;
    if (state['done'] == null) state['done'] = <String, dynamic>{};
    if (state['easy'] == null) state['easy'] = <String, dynamic>{};
    await XpService.saveDayState(day, state);
    setState(() {});
  }

  bool _isDone(String id) => (state['done'] as Map).containsKey(id) ? (state['done'][id] == true) : false;
  bool _isEasy(String id) => (state['easy'] as Map).containsKey(id) ? (state['easy'][id] == true) : false;

  int _dayXp() => (state['dayXp'] as int?) ?? 0;

  int _questXp(Quest q) => XpService.questXp(q, easyMode: _isEasy(q.id));

  Future<void> _toggleDone(Quest q, bool v) async {
    final done = Map<String, dynamic>.from(state['done'] as Map);
    final easy = Map<String, dynamic>.from(state['easy'] as Map);
    final wasDone = done[q.id] == true;

    // compute delta xp based on change
    final xpVal = XpService.questXp(q, easyMode: (easy[q.id] == true));
    int dayXp = _dayXp();
    int newTotal = totalXp;

    if (!wasDone && v) {
      dayXp += xpVal;
      newTotal += xpVal;
    } else if (wasDone && !v) {
      dayXp -= xpVal;
      newTotal -= xpVal;
    }

    done[q.id] = v;
    state['done'] = done;
    state['dayXp'] = dayXp;

    totalXp = newTotal;
    await XpService.setTotalXp(totalXp);
    await XpService.saveDayState(day, state);

    // Minimum day = 3 quests complete
    final completed = done.values.where((x) => x == true).length;
    await XpService.updateMinDayAchieved(day: day, achieved: completed >= 3);

    setState(() {});
  }

  Future<void> _toggleEasy(Quest q, bool v) async {
    final done = Map<String, dynamic>.from(state['done'] as Map);
    final easy = Map<String, dynamic>.from(state['easy'] as Map);

    final wasEasy = easy[q.id] == true;
    final isDone = done[q.id] == true;

    // if quest already done, changing easy mode changes xp
    int dayXp = _dayXp();
    int newTotal = totalXp;

    if (isDone) {
      final oldXp = XpService.questXp(q, easyMode: wasEasy);
      final newXp = XpService.questXp(q, easyMode: v);
      final delta = newXp - oldXp;
      dayXp += delta;
      newTotal += delta;
    }

    easy[q.id] = v;
    state['easy'] = easy;
    state['dayXp'] = dayXp;

    totalXp = newTotal;
    await XpService.setTotalXp(totalXp);
    await XpService.saveDayState(day, state);

    setState(() {});
  }

  String _rankFromXp(int xp) {
    if (xp >= 125) return 'S';
    if (xp >= 100) return 'A';
    if (xp >= 75) return 'B';
    if (xp >= 50) return 'C';
    if (xp >= 25) return 'D';
    return 'E';
  }

  @override
  Widget build(BuildContext context) {
    final doneMap = (state['done'] as Map?) ?? {};
    final completed = doneMap.values.where((x) => x == true).length;
    final dayXp = _dayXp();
    final rank = _rankFromXp(dayXp);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dungeon Daily — $day'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Text('Rank $rank  •  $completed/10')),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text('XP today: $dayXp   •   Total XP: $totalXp'),
            ),
          ),
          const SizedBox(height: 10),
          for (final q in quests)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _isDone(q.id),
                          onChanged: (v) => _toggleDone(q, v ?? false),
                        ),
                        Expanded(
                          child: Text(
                            _isEasy(q.id) ? q.easyTitle : q.title,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${_questXp(q)} XP'),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 48),
                        Expanded(
                          child: Row(
                            children: [
                              const Text('Easy Mode'),
                              Switch(
                                value: _isEasy(q.id),
                                onChanged: (v) => _toggleEasy(q, v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Knee flare override: if knee pain is high, your streak saver is:\n'
                'Hydration Rune + Knee Armor + System Log (3 quests).',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
