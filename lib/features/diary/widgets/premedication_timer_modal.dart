import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../reminders/services/notification_service.dart';

class PremedicationTimerModal extends StatefulWidget {
  const PremedicationTimerModal({super.key});

  @override
  State<PremedicationTimerModal> createState() => _PremedicationTimerModalState();
}

class _PremedicationTimerModalState extends State<PremedicationTimerModal> {
  int _totalSeconds = 15 * 60;
  int _secondsRemaining = 15 * 60;
  Timer? _timer;
  bool _isRunning = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final NotificationService _notifService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final duration = prefs.getInt('hyqvia_timer_duration') ?? 15;
    setState(() {
      _totalSeconds = duration * 60;
      _secondsRemaining = _totalSeconds;
    });
  }

  Future<void> _saveSettings(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hyqvia_timer_duration', minutes);
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() => _isRunning = true);
    
    // Schedule background pings
    _notifService.schedulePremedicationTimer(_secondsRemaining ~/ 60);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
          
          // "Bimmeln" every 60 seconds (at the start of each new minute)
          if (_secondsRemaining > 0 && _secondsRemaining % 60 == 0) {
            _playMinutePing();
          }
        });
      } else {
        _stopTimer();
        _playFinalSound();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _notifService.cancelPremedicationTimer();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _stopTimer();
    setState(() => _secondsRemaining = _totalSeconds);
  }

  Future<void> _playMinutePing() async {
    // Repeat the ping 3 times with a 1.5s delay
    for (int i = 0; i < 3; i++) {
      try {
        await _audioPlayer.play(AssetSource('audio/ping.mp3'));
      } catch (_) {
        // Fallback or ignore
      }
      if (i < 2) await Future.delayed(const Duration(milliseconds: 1500));
    }
  }

  Future<void> _playFinalSound() async {
    // Final bell repeats 4 times
    for (int i = 0; i < 4; i++) {
      try {
        await _audioPlayer.play(AssetSource('audio/bell.mp3'));
      } catch (_) {
        // Fallback
      }
      if (i < 3) await Future.delayed(const Duration(milliseconds: 2000));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    final progress = 1 - (_secondsRemaining / _totalSeconds);
    final remainingMl = (_secondsRemaining / 60).ceil();

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
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Vormedikation Timer',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ping jede Minute • 15 Min empfohlen',
            style: TextStyle(color: Colors.grey),
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
                  backgroundColor: Colors.teal.withOpacity(0.1),
                  color: Colors.teal,
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
                  const Text('verbleibend', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.vaccines_rounded, size: 16, color: Colors.teal),
                        const SizedBox(width: 6),
                        Text(
                          '${(remainingMl).toStringAsFixed(0)} ml',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
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
                    Text('${(remainingMl).toStringAsFixed(0)} / ${_totalSeconds ~/ 60} ml', 
                         style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                              colors: [Colors.teal.shade300, Colors.teal],
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
                iconColor: Colors.black54,
              ),
              const SizedBox(width: 24),
              _buildControlButton(
                icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                onPressed: _isRunning ? _stopTimer : _startTimer,
                color: Colors.teal,
                iconColor: Colors.white,
                size: 80,
              ),
              const SizedBox(width: 24),
              _buildControlButton(
                icon: Icons.timer_outlined,
                onPressed: _isRunning ? null : _showDurationPicker,
                color: Colors.grey.shade200,
                iconColor: Colors.black54,
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
          color: onPressed == null ? color.withOpacity(0.5) : color,
          shape: BoxShape.circle,
          boxShadow: [
            if (onPressed != null)
              BoxShadow(
                color: color.withOpacity(0.3),
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
            const Text('Dauer anpassen (Minuten)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              children: [5, 10, 15, 20, 30].map((m) => ChoiceChip(
                label: Text('$m min'),
                selected: _totalSeconds == m * 60,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _totalSeconds = m * 60;
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
