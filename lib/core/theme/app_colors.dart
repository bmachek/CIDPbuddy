import 'package:flutter/material.dart';

/// Status colours that are not part of Material's [ColorScheme]: success,
/// warning, and the muted "inactive" tone. They come in a light and a dark
/// variant so they keep WCAG AA contrast on both surfaces — a hard-coded
/// `Colors.green` or `Colors.grey` does not.
///
/// ```dart
/// final status = AppStatusColors.of(context);
/// Icon(Icons.check, color: status.success);
/// ```
@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.inactive,
    required this.accentText,
  });

  /// "Done", "delivered", "all good".
  final Color success;

  /// Text or icons drawn on a [success] fill.
  final Color onSuccess;

  /// "Low stock", "backup outdated" — needs attention but nothing is broken.
  final Color warning;

  /// Text or icons drawn on a [warning] fill.
  final Color onWarning;

  /// Discontinued medications, past appointments — present but not current.
  final Color inactive;

  /// The brand blue at a tone that passes WCAG AA as *small text* on the
  /// current surface — section headers, captions, "next infusion" lines.
  /// `colorScheme.primary` itself only reaches ~4.3:1 on the light gradient
  /// and ~3.3:1 on the dark one; keep it for fills and large accents.
  final Color accentText;

  /// Green 800 / orange 900 on the light surface: both ≥ 4.5:1 on white.
  static const AppStatusColors light = AppStatusColors(
    success: Color(0xFF2E7D32),
    onSuccess: Colors.white,
    warning: Color(0xFFB45309),
    onWarning: Colors.white,
    inactive: Color(0xFF6B6F7A),
    accentText: Color(0xFF0052CC),
  );

  /// Lighter tints for the dark surface, where saturated colours sink.
  static const AppStatusColors dark = AppStatusColors(
    success: Color(0xFF81C784),
    onSuccess: Colors.black,
    warning: Color(0xFFFFB74D),
    onWarning: Colors.black,
    inactive: Color(0xFFA0A4B0),
    accentText: Color(0xFF8AB4FF),
  );

  static AppStatusColors of(BuildContext context) =>
      Theme.of(context).extension<AppStatusColors>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  @override
  AppStatusColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? inactive,
    Color? accentText,
  }) => AppStatusColors(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    inactive: inactive ?? this.inactive,
    accentText: accentText ?? this.accentText,
  );

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) return this;
    return AppStatusColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      inactive: Color.lerp(inactive, other.inactive, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
    );
  }
}
