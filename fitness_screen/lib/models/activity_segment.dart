import 'dart:ui';

class ActivitySegment {
  const ActivitySegment({
    required this.label,
    required this.percent,
    required this.color,
  });
  final String label;
  final int percent;
  final Color color;
}
