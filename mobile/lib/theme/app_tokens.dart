import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.radiusField,
    required this.radiusButton,
    required this.radiusCard,
    required this.durationFast,
  });

  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;
  final double radiusField;
  final double radiusButton;
  final double radiusCard;
  final Duration durationFast;

  static const standard = AppTokens(
    spaceXs: 4,
    spaceSm: 8,
    spaceMd: 16,
    spaceLg: 24,
    spaceXl: 32,
    radiusField: 8,
    radiusButton: 8,
    radiusCard: 8,
    durationFast: Duration(milliseconds: 180),
  );

  @override
  AppTokens copyWith({
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? radiusField,
    double? radiusButton,
    double? radiusCard,
    Duration? durationFast,
  }) {
    return AppTokens(
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      radiusField: radiusField ?? this.radiusField,
      radiusButton: radiusButton ?? this.radiusButton,
      radiusCard: radiusCard ?? this.radiusCard,
      durationFast: durationFast ?? this.durationFast,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;

    return AppTokens(
      spaceXs: lerpDouble(spaceXs, other.spaceXs, t)!,
      spaceSm: lerpDouble(spaceSm, other.spaceSm, t)!,
      spaceMd: lerpDouble(spaceMd, other.spaceMd, t)!,
      spaceLg: lerpDouble(spaceLg, other.spaceLg, t)!,
      spaceXl: lerpDouble(spaceXl, other.spaceXl, t)!,
      radiusField: lerpDouble(radiusField, other.radiusField, t)!,
      radiusButton: lerpDouble(radiusButton, other.radiusButton, t)!,
      radiusCard: lerpDouble(radiusCard, other.radiusCard, t)!,
      durationFast: lerpDuration(durationFast, other.durationFast, t),
    );
  }

  Duration lerpDuration(Duration a, Duration b, double t) {
    return Duration(
      milliseconds: lerpDouble(a.inMilliseconds, b.inMilliseconds, t)!.round(),
    );
  }
}

extension AppTokensReader on BuildContext {
  AppTokens get tokens =>
      Theme.of(this).extension<AppTokens>() ?? AppTokens.standard;
}
