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

    // First-time setup
    if (!secretEnabled) {
      if (!mounted) return;
      await _showSetupPinsDialog();
      return;
    }

    // Biometric first
    final okBio = await LockService.biometricAuth();
    if (okBio) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
      return;
    }

    // Fallback PIN
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
            const Text('Create a PIN for SYSTEM.\nCreate a Panic PIN that keeps you in Decoy Mode.'),
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
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeShell()),
                );
                return;
              }
              _toast('ERROR 0xSAVAGE: Wrong PIN.');
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
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
                  _toast('Installing more RAM…');
                  Future.delayed(const Duration(milliseconds: 350), _unlockFlow);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '🪟 SYSTEM 3.11 FOR WORKGROUPS\n(Definitely Legit)',
                  textAlign: TextAlign.center,
                ),
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
            // Fake title bar (long-press = unlock)
            GestureDetector(
              onLongPress: _unlockFlow,
              child: Container(
                color: Colors.blueGrey.shade800,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: const Row(
                  children: [
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

            // Fake Program Manager
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
                          _IconButton(label: 'Totally Normal Files', icon: '📁', onTap: () => _toast('Folder opened: TAXES_1997')),
                          _IconButton(label: 'Brain Tips', icon: '🧠', onTap: () => _toast('Tip: Sleep is not optional.')),
                          _IconButton(label: 'Motivation 95', icon: '💬', onTap: () => _toast('Quote: “Discipline is spite with a calendar.”')),
                          _IconButton(label: 'Minesweeper', icon: '🕹', onTap: () => _toast('BOOM. Productivity exploded.')),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(border: Border.all(color: Colors.black54)),
                        child: const Text(
                          'Status: Ready.\nWarning: Productivity levels exceed safe limits.\nInsert coffee to continue.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _MenuItem({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        child: Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;
  const _IconButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87))),
          ],
        ),
      ),
    );
  }
}
