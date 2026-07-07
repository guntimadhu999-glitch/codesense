import 'package:flutter/material.dart';

import '../theme.dart';

/// Pop-in severity chip (scale 0.5 + rotate -10deg -> scale 1 + rotate 0).
class SeverityChip extends StatefulWidget {
  const SeverityChip({super.key, required this.severity});

  final String severity;

  @override
  State<SeverityChip> createState() => _SeverityChipState();
}

class _SeverityChipState extends State<SeverityChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  )..forward();

  late final Animation<double> _scale = Tween<double>(begin: 0.5, end: 1).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
  );
  late final Animation<double> _rotation =
      Tween<double>(begin: -10 * 3.1415926 / 180, end: 0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ({String emoji, Color color, String label}) get _meta {
    switch (widget.severity.toLowerCase()) {
      case 'critical':
        return (emoji: '🔴', color: AppColors.danger, label: 'Critical');
      case 'warning':
        return (emoji: '🟡', color: AppColors.warning, label: 'Warning');
      default:
        return (emoji: '🔵', color: AppColors.electricBlue, label: 'Minor');
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = _meta;
    return ScaleTransition(
      scale: _scale,
      child: AnimatedBuilder(
        animation: _rotation,
        builder: (context, child) =>
            Transform.rotate(angle: _rotation.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: m.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: m.color.withValues(alpha: 0.5)),
          ),
          child: Text(
            '${m.emoji} ${m.label}',
            style: AppTheme.ui(size: 12, weight: FontWeight.w600, color: m.color),
          ),
        ),
      ),
    );
  }
}
