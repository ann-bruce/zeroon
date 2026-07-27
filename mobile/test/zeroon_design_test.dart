import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/common/zeroon_design.dart';

void main() {
  test('insight card text remains readable over the brightest surface', () {
    expect(
        _contrastRatio(zeroonInsightText, zeroonInsightGlow), greaterThan(7));
    expect(
      _contrastRatio(zeroonInsightLabel, zeroonInsightGlow),
      greaterThan(4.5),
    );
    expect(
      _contrastRatio(zeroonInsightMuted, zeroonInsightGlow),
      greaterThan(4.5),
    );
  });
}

double _contrastRatio(Color foreground, Color background) {
  final lighter = foreground.computeLuminance();
  final darker = background.computeLuminance();
  return (lighter + 0.05) / (darker + 0.05);
}
