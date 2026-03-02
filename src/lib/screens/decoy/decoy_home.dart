import 'package:flutter/material.dart';
import '../../services/lock_service.dart';
import '../real/home_shell.dart';

class DecoyHome extends StatefulWidget {
  const DecoyHome({super.key});

  @override
  State<DecoyHome> createState() => _DecoyHomeState();
}

class _DecoyHomeState extends State<DecoyHome> {
  int helpTapCount = 0;
  int logoTapCount = 0;

  Future<void> _unlockFlow() async {
    final secretEnabled = await LockService.isSecretEnabled();

    // First-time setup (set PINs) if secret not enabled yet
    if (!secretEnabled) {
      if (!mounted) return;
      await _showSetupPinsDialog();
      return;
    }

    // Attempt biometric first
    final okBio = await LockService.biometricAuth();
    if (okBio) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
      return;
    }

    // Fallback to PIN
    if (!mounted) return;
    await _showPinDialog();
  }

  Future<void> _showSetupPinsDialog() async {
    final pinCtrl = TextEditingController();
    final panicCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('SYSTEM 3.1 Setup Wizard (Totally Real)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Create a PIN for SYSTEM. Also create a Panic PIN that keeps you in Decoy Mode.'),
            const SizedBox(height: 12),
            TextField(
              controller: pinCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'PIN (4+ digits)'),
            ),
            TextField(
              controller: panicCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Panic PIN (different)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final pin = pinCtrl.text.trim();
              final panic = panicCtrl.text.trim();
              if (pin.length < 4 || panic.length < 4 || pin == panic) return;
              await LockService.setPins(pin: pin, panicPin: panic);
              if (!mounted) return;
              Navigator.pop(context);
              _toast('Setup complete. SYSTEM is armed.');
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPinDialog() async {
    final ctrl = TextEditingController();
    final pin = await LockService.getPin();
    final panic = await LockService.getPanicPin();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter PIN'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'PIN'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final entered = ctrl.text.trim();
              if (entered == panic) {
                Navigator.pop(context);
                _toast('Access granted: Guest Productivity Mode.');
                return;
              }
              if (entered == pin) {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
                return;
              }
              _toast('ERROR 0xSAVAGE: Wrong PIN. Too much power detected.');
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  void _helpTapped() {
    setState(() => helpTapCount++);
    if (helpTapCount >= 5) {
      helpTapCount = 0;
      _showAbout();
    }
  }

  void _showAbout() {
    logoTapCount = 0;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About SYSTEM 3.1'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                logoTapCount++;
                if (logoTapCount >= 7) {
                  Navigator.pop(context);
                  _toast('ERROR: Productivity overflow. Switching systems…');
                  Future.delayed(const Duration(milliseconds: 400), _unlockFlow);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('🪟 SYSTEM 3.11 FOR WORKGROUPS\n(Definitely Legit)', textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Tap the logo 7 times to install more RAM.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grey = const Color(0xFFBDBDBD);

    return Scaffold(
      backgroundColor: grey,
      body: SafeArea(
        child: Column(
          children: [
            // Fake title bar
            GestureDetector(
              onLongPress: _unlockFlow,
              child: Container(
                color: Colors.blueGrey.shade800,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: const [
                    Text('SYSTEM 3.1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    Expanded(child: Text('Productivity Shell (Not Suspicious)', style: TextStyle(color: Colors.white70))),
                  ],
                ),
              ),
            ),

            // Menu bar
            Container(
              color: grey,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  _MenuItem(text: 'File', onTap: () => _toast('Insert floppy to continue.')),
                  _MenuItem(text: 'Edit', onTap: () => _toast('Undo is a premium feature in 1993.')),
                  _MenuItem(text: 'View', onTap: () => _toast('Viewing… intensely.')),
                  _MenuItem(text: 'Window', onTap: () => _toast('Too many windows. Not enough discipline.')),
                  _MenuItem(text: 'Help', onTap: _helpTapped),
                ],
              ),
            ),

            // Fake Program Manager window
            Expanded(
              child: Center(
                child: Container(
                  width: 340,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    border: Border.all(color: Colors.black87, width: 2),
                    boxShadow: const [BoxShadow(blurRadius: 0, spreadRadius: 1, offset: Offset(3, 3))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.blueGrey.shade900,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: const Text('Program Manager', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _IconButton(label: 'Calc-U-L8R', icon: '🧮', onTap: () => _toast('Calculating your excuses…')),
                          _IconButton(label: 'Notepad of Destiny', icon: '📝', onTap: () => _toast('Saving to floppy… (99% done)')),
                          _IconButton(label

cat > src/lib/screens/real/home_shell.dart <<'EOF'
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
cat > src/lib/screens/real/quests.dart <<'EOF'
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
    Quest(id: 'steps', title: 'Step Quest — 10 min OR 1000 steps', xp: 20, easyTitle: 'Step Quest — 5
cat > src/lib/screens/real/quests.dart <<'EOF'
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
