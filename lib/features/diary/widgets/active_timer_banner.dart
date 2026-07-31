import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'premedication_timer_modal.dart';

/// Re-entry point for a running or paused Vormedikation timer.
///
/// The timer modal is a bottom sheet, so a downward swipe dismisses it while
/// the countdown keeps running in the background service. Without a way back
/// in, the timer was unreachable until the next logged infusion. This banner
/// shows up on the dashboard for as long as the service reports an open timer
/// session and reopens the modal on tap.
class ActiveTimerBanner extends StatefulWidget {
  const ActiveTimerBanner({super.key});

  @override
  State<ActiveTimerBanner> createState() => _ActiveTimerBannerState();
}

class _ActiveTimerBannerState extends State<ActiveTimerBanner>
    with WidgetsBindingObserver {
  StreamSubscription? _serviceSubscription;
  bool _sessionActive = false;
  bool _isRunning = false;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final service = FlutterBackgroundService();
    _serviceSubscription = service.on('timerUpdate').listen((event) {
      if (!mounted || event == null) return;
      setState(() {
        _isRunning = event['isRunning'] as bool? ?? false;
        _sessionActive = event['sessionActive'] as bool? ?? _isRunning;
        _secondsRemaining = event['secondsRemaining'] as int? ?? 0;
      });
    });
    service.invoke('getTimerState');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // On iOS the service isolate is starved while backgrounded, so its
      // periodic tick has not been broadcasting. Ask for the current state
      // instead of showing whatever was last received.
      FlutterBackgroundService().invoke('getTimerState');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceSubscription?.cancel();
    super.dispose();
  }

  void _openTimer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PremedicationTimerModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_sessionActive) return const SizedBox.shrink();

    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    final timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final accent = Theme.of(context).colorScheme.tertiary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: _openTimer,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  _isRunning ? Icons.av_timer_rounded : Icons.pause_circle_outline_rounded,
                  color: accent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isRunning
                            ? 'Vormedikation Timer läuft'
                            : 'Vormedikation Timer pausiert',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$timeText verbleibend • Tippen zum Öffnen',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
