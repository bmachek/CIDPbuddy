import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';
import 'package:cidpbuddy/core/services/background_service.dart';

class PremedicationTimerModal extends StatefulWidget {
  const PremedicationTimerModal({super.key});

  @override
  State<PremedicationTimerModal> createState() =>
      _PremedicationTimerModalState();
}

class _PremedicationTimerModalState extends State<PremedicationTimerModal> {
  int _totalSeconds = 15 * 60;
  int _secondsRemaining = 15 * 60;
  bool _isRunning = false;
  StreamSubscription? _serviceSubscription;

  /// The countdown runs inside the background service, which only exists on
  /// Android and iOS. Elsewhere `FlutterBackgroundService()` throws, so every
  /// call is gated and the controls are shown disabled.
  static bool get _hasService => BackgroundService.isSupportedPlatform;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final ml = prefs.getInt('hyqvia_timer_ml') ?? 15;
    setState(() {
      _totalSeconds = (ml - 1) * 60;
      _secondsRemaining = _totalSeconds;
    });

    if (!_hasService) return;
    final service = FlutterBackgroundService();

    // Listen to background service updates. Only adopt the service's remaining
    // seconds while a session is active — otherwise the service reports its
    // idle counter (0) and the UI would jump to the end. A paused session
    // still counts, so reopening the modal after a swipe-away restores the
    // remaining time instead of silently resetting to the full duration.
    _serviceSubscription = service.on('timerUpdate').listen((event) {
      if (!mounted || event == null) return;
      final running = event['isRunning'] as bool? ?? false;
      final sessionActive = event['sessionActive'] as bool? ?? running;
      final remaining = event['secondsRemaining'] as int?;
      setState(() {
        _isRunning = running;
        if (sessionActive && remaining != null) {
          _secondsRemaining = remaining;
        }
      });
    });

    // Ask the background service for the actual timer state (not the
    // service's own running flag, which is always true since it runs 24/7).
    service.invoke('getTimerState');
  }

  Future<void> _saveSettings(int ml) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hyqvia_timer_ml', ml);
  }

  void _startTimer() {
    if (_isRunning || !_hasService) return;

    FlutterBackgroundService().invoke('startTimer', {
      'seconds': _secondsRemaining,
    });

    setState(() => _isRunning = true);
    WakelockPlus.enable();
  }

  void _stopTimer() {
    if (!_hasService) return;
    FlutterBackgroundService().invoke('stopTimer');
    setState(() => _isRunning = false);
    WakelockPlus.disable();
  }

  void _resetTimer() {
    // Ends the session in the service too, so no "Timer läuft" entry point
    // survives a reset.
    if (_hasService) {
      FlutterBackgroundService().invoke('resetTimer', {
        'seconds': _totalSeconds,
      });
    }
    setState(() {
      _isRunning = false;
      _secondsRemaining = _totalSeconds;
    });
    WakelockPlus.disable();
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
    final progress =
        1 - (_secondsRemaining / (_totalSeconds > 0 ? _totalSeconds : 1));
    final totalMl = (_totalSeconds ~/ 60) + 1;
    final remainingMl = (minutes + 1);
    final numberFormat = NumberFormat.decimalPattern(context.localeTag);
    final remainingMlText = context.l10n.millilitersShort(
      numberFormat.format(remainingMl),
    );
    final progressText = context.l10n.millilitersProgress(
      numberFormat.format(remainingMl),
      numberFormat.format(totalMl),
    );
    final clockText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.timerTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.timerSubtitle(_totalSeconds ~/ 60),
                style: TextStyle(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Circular Timer with Volume Display
              MergeSemantics(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: colorScheme.tertiary.withValues(
                          alpha: 0.1,
                        ),
                        color: colorScheme.tertiary,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          clockText,
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          context.l10n.timerRemainingLabel,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.vaccines_rounded,
                                size: 16,
                                color: colorScheme.tertiary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                remainingMlText,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
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
              ),

              const SizedBox(height: 32),

              // Syringe Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.l10n.timerSyringeProgress,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            progressText,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Semantics(
                      label: progressText,
                      excludeSemantics: true,
                      child: Container(
                        height: 24,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Stack(
                          children: [
                            FractionallySizedBox(
                              // Inverted: progress is the time passed, the
                              // bar shows what is left in the syringe.
                              widthFactor: 1 - progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.tertiary.withValues(
                                        alpha: 0.7,
                                      ),
                                      colorScheme.tertiary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                            ),
                            Center(
                              child: Icon(
                                Icons.keyboard_double_arrow_right_rounded,
                                color: colorScheme.onTertiary,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
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
                    tooltip: context.l10n.tooltipTimerReset,
                    onPressed: _hasService ? _resetTimer : null,
                    color: colorScheme.surfaceContainerHighest,
                    iconColor: colorScheme.onSurface,
                  ),
                  const SizedBox(width: 24),
                  _buildControlButton(
                    icon: _isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    tooltip: _isRunning
                        ? context.l10n.tooltipTimerPause
                        : context.l10n.tooltipTimerStart,
                    onPressed: !_hasService
                        ? null
                        : (_isRunning ? _stopTimer : _startTimer),
                    color: colorScheme.tertiary,
                    iconColor: colorScheme.onTertiary,
                    size: 80,
                  ),
                  const SizedBox(width: 24),
                  _buildControlButton(
                    icon: Icons.timer_outlined,
                    tooltip: context.l10n.tooltipTimerDuration,
                    onPressed: _isRunning ? null : _showDurationPicker,
                    color: colorScheme.surfaceContainerHighest,
                    iconColor: colorScheme.onSurface,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    required Color color,
    required Color iconColor,
    double size = 60,
  }) {
    final enabled = onPressed != null;
    // The tooltip is what a screen reader announces (like IconButton does
    // it); the Semantics wrapper marks the node as a button and reflects the
    // disabled state.
    //
    // The circle has to be painted by a Material of its own, not by an `Ink`
    // decoration: `Ink` hands its decoration to the nearest Material ancestor,
    // which here is the bottom sheet's — and that Material paints its ink
    // features *below* its child, so the modal's own opaque background
    // container covered every circle. All that was left of the play button
    // was its icon, in onTertiary: white on the light background, black on
    // the dark one, invisible either way.
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        child: Material(
          color: enabled ? color : color.withValues(alpha: 0.5),
          shape: const CircleBorder(),
          elevation: enabled ? 6 : 0,
          shadowColor: color.withValues(alpha: 0.4),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                icon,
                color: enabled ? iconColor : iconColor.withValues(alpha: 0.6),
                size: size * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDurationPicker() {
    final numberFormat = NumberFormat.decimalPattern(context.localeTag);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.timerVolumePickerTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [5, 10, 15, 20, 30]
                      .map(
                        (m) => ChoiceChip(
                          label: Text(
                            context.l10n.millilitersShort(
                              numberFormat.format(m),
                            ),
                          ),
                          selected: ((_totalSeconds ~/ 60) + 1) == m,
                          onSelected: (selected) {
                            if (!selected) return;
                            setState(() {
                              _totalSeconds = (m - 1) * 60;
                              _secondsRemaining = _totalSeconds;
                            });
                            // Discard any paused session so the service does
                            // not push the old remaining time back onto the
                            // new duration.
                            if (_hasService) {
                              FlutterBackgroundService().invoke('resetTimer', {
                                'seconds': _totalSeconds,
                              });
                            }
                            _saveSettings(m);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
