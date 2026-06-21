import 'dart:math' as math;

import 'package:flutter/material.dart';

const zeroonPaper = Color(0xFFFAF7F1);
const zeroonIvory = Color(0xFFF2EEE6);
const zeroonInk = Color(0xFF222730);
const zeroonNight = Color(0xFF1F2430);
const zeroonMuted = Color(0xFF85858A);
const zeroonGold = Color(0xFFD7B46A);
const zeroonCyan = Color(0xFF6CB7C8);
const zeroonBlue = Color(0xFF4AA8FF);
const zeroonLine = Color(0x1C1F2430);

TextStyle zeroonSerif(
  BuildContext context, {
  double size = 28,
  FontWeight weight = FontWeight.w600,
  Color color = zeroonInk,
}) {
  return TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: -size * 0.015,
    height: 1.2,
  );
}

class ZeroonScreen extends StatelessWidget {
  const ZeroonScreen({
    super.key,
    required this.child,
    this.bottomNavigationBar,
  });

  final Widget child;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: zeroonPaper,
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(1.15, -1.08),
            radius: 0.82,
            colors: [Color(0x176CB7C8), zeroonPaper],
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}

class ZeroonHeader extends StatelessWidget {
  const ZeroonHeader({
    super.key,
    this.mark,
    required this.title,
    this.action,
    this.leading,
    this.center = false,
  });

  final String? mark;
  final String title;
  final Widget? action;
  final Widget? leading;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final titleBlock = Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mark != null) SectionMark(mark!),
        const SizedBox(height: 5),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Row(
        children: [
          leading ?? const SizedBox(width: 38),
          Expanded(child: center ? Center(child: titleBlock) : titleBlock),
          action ?? const SizedBox(width: 38),
        ],
      ),
    );
  }
}

class SectionMark extends StatelessWidget {
  const SectionMark(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF9A8D75),
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
      ),
    );
  }
}

class Wordmark extends StatelessWidget {
  const Wordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'ZEROON',
      style: TextStyle(
        color: zeroonInk,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 3,
      ),
    );
  }
}

class ZeroonIconButton extends StatelessWidget {
  const ZeroonIconButton({
    super.key,
    required this.child,
    this.onPressed,
    this.dark = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: dark ? zeroonNight : Colors.white.withValues(alpha: 0.62),
          shape: BoxShape.circle,
          border: Border.all(color: zeroonLine),
        ),
        child: IconTheme(
          data: IconThemeData(
            color: dark ? zeroonIvory : zeroonInk,
            size: 18,
          ),
          child: child,
        ),
      ),
    );
  }
}

class ZeroonPrimaryButton extends StatelessWidget {
  const ZeroonPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: zeroonNight,
          foregroundColor: zeroonIvory,
          disabledBackgroundColor: zeroonNight.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 18),
            Text(loading ? '处理中...' : label),
            const Icon(Icons.arrow_forward, size: 18),
          ],
        ),
      ),
    );
  }
}

class ZeroonCard extends StatelessWidget {
  const ZeroonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: zeroonLine),
      ),
      child: child,
    );
    if (onTap == null) {
      return card;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: card,
    );
  }
}

class StateCore extends StatelessWidget {
  const StateCore({super.key, this.size = 168, this.state = 'IDLE'});

  final double size;
  final String state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _StateCorePainter(state: state)),
    );
  }
}

class _StateCorePainter extends CustomPainter {
  const _StateCorePainter({required this.state});

  final String state;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9;

    for (var i = 0; i < 72; i++) {
      final start = i * math.pi / 36;
      ringPaint.color =
          i.isEven ? zeroonNight : zeroonGold.withValues(alpha: 0.75);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 18),
        start,
        math.pi / 62,
        false,
        ringPaint,
      );
    }

    final accent = stateColor(state);
    final deep = switch (state) {
      'IDLE' => const Color(0xFF2D343D),
      'CALM' => const Color(0xFF39414B),
      'CREATE' => const Color(0xFF6B451A),
      'TIRED' => const Color(0xFF34353B),
      'OVERLOAD' => const Color(0xFF5B1723),
      'CONFUSED' => const Color(0xFF172240),
      _ => const Color(0xFF173C84),
    };

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          Color.lerp(Colors.white, accent, 0.28)!,
          accent,
          deep,
          const Color(0xFF0D1528),
        ],
        stops: const [0.03, 0.16, 0.38, 0.58, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 33));
    canvas.drawCircle(center, radius - 33, glowPaint);

    final halo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.white.withValues(alpha: 0.75);
    canvas.drawCircle(center, radius * 0.28, halo);
    canvas.drawCircle(center, radius * 0.19,
        halo..color = Colors.white.withValues(alpha: 0.55));

    canvas.drawCircle(
      center,
      8,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(covariant _StateCorePainter oldDelegate) {
    return oldDelegate.state != state;
  }
}

Color stateColor(String state) {
  return switch (state) {
    'IDLE' => zeroonCyan,
    'CALM' => const Color(0xFFEDEDED),
    'FOCUS' => zeroonBlue,
    'CREATE' => const Color(0xFFFFD166),
    'TIRED' => const Color(0xFF8F8F93),
    'OVERLOAD' => const Color(0xFFFF4D4D),
    'CONFUSED' => const Color(0xFF283F67),
    _ => zeroonCyan,
  };
}

String stateLabel(String state) {
  return switch (state) {
    'IDLE' => '等待',
    'CALM' => '平静',
    'FOCUS' => '专注',
    'CREATE' => '创造',
    'TIRED' => '疲惫',
    'OVERLOAD' => '高负荷',
    'CONFUSED' => '混乱',
    _ => state,
  };
}
