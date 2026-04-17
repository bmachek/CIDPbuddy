import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class PremedicationTimerModal extends StatefulWidget {
  const PremedicationTimerModal({super.key});

  @override
  State<PremedicationTimerModal> createState() => _PremedicationTimerModalState();
}

class _PremedicationTimerModalState extends State<PremedicationTimerModal> {
  int _totalSeconds = 15 * 60;
  int _secondsRemaining = 15 * 60;
  bool _isRunning = false;
  StreamSubscription? _serviceSubscription;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final ml = prefs.getInt('hyqvia_timer_ml') ?? 15;
    setState(() {
      _totalSeconds = (ml - 1) * 60;
      _secondsRemaining = _totalSeconds;
    });

    // Listen to background service updates
    _serviceSubscription = FlutterBackgroundService().on('timerUpdate').listen((event) {
      if (mounted && event != null) {
        setState(() {
          _secondsRemaining = event['secondsRemaining'] as int? ?? _secondsRemaining;
          _isRunning = event['isRunning'] as bool? ?? _isRunning;
        });
      }
    });

    // Check current status
    final isRunning = await FlutterBackgroundService().isRunning();
    setState(() {
      _isRunning = isRunning;
    });
  }

  Future<void> _saveSettings(int ml) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hyqvia_timer_ml', ml);
  }

  void _startTimer() {
    if (_isRunning) return;

    FlutterBackgroundService().invoke('startTimer', {
      'seconds': _secondsRemaining,
    });
    
    setState(() => _isRunning = true);
    WakelockPlus.enable();
  }

  void _stopTimer() {
    FlutterBackgroundService().invoke('stopTimer');
    setState(() => _isRunning = false);
    WakelockPlus.disable();
  }

  void _resetTimer() {
    _stopTimer();
    setState(() => _secondsRemaining = _totalSeconds);
  }

  @override
  void dispose() {
    _serviceSubscription?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    final progress = 1 - (_secondsRemaining / (_totalSeconds > 0 ? _totalSeconds : 1));
    final totalMl = (_totalSeconds ~/ 60) + 1;
    final remainingMl = (minutes + 1);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Vormedikation Timer',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Pin jede Minute • $_totalSeconds Sek. Timer',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 40),
          
          // Circular Timer with Volume Display
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                  color: Theme.of(context).colorScheme.tertiary,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text('verbleibend', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.vaccines_rounded, size: 16, color: Theme.of(context).colorScheme.tertiary),
                        const SizedBox(width: 6),
                        Text(
                          '${(remainingMl).toStringAsFixed(0)} ml',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.tertiary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Syringe Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Spritzen-Fortschritt', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    Text('$remainingMl / $totalMl ml', 
                         style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: 1 - progress, // Inverting because progress is time passed, we want time remaining
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.7), Theme.of(context).colorScheme.tertiary],
                            ),
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                      ),
                      const Center(
                        child: Icon(Icons.keyboard_double_arrow_right_rounded, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: Icons.refresh_rounded,
                onPressed: _resetTimer,
                color: Colors.grey.shade200,
                iconColor: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 24),
              _buildControlButton(
                icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                onPressed: _isRunning ? _stopTimer : _startTimer,
                color: Theme.of(context).colorScheme.tertiary,
                iconColor: Colors.white,
                size: 80,
              ),
              const SizedBox(width: 24),
              _buildControlButton(
                icon: Icons.timer_outlined,
                onPressed: _isRunning ? null : _showDurationPicker,
                color: Colors.grey.shade200,
                iconColor: Theme.of(context).colorScheme.onSurface,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
    required Color iconColor,
    double size = 60,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: onPressed == null ? color.withValues(alpha: 0.5) : color,
          shape: BoxShape.circle,
          boxShadow: [
            if (onPressed != null)
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Vormedikation Menge (ml)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              children: [5, 10, 15, 20, 30].map((m) => ChoiceChip(
                label: Text('$m ml'),
                selected: ((_totalSeconds ~/ 60) + 1) == m,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _totalSeconds = (m - 1) * 60;
                      _secondsRemaining = _totalSeconds;
                    });
                    _saveSettings(m);
                    Navigator.pop(context);
                  }
                },
              )).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
